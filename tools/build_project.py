"""Turn the parsed place tree into a Rojo project that contains every script.

Non-script instances that sit on the path to a script become directories
(with init.meta.json setting className when not a Folder). Any directory or
script whose original instance had non-script children (UI, remotes, values,
parts) gets ignoreUnknownInstances so syncing never deletes them.
"""
import json, os, re, sys
from collections import defaultdict

ARGS = [a for a in sys.argv[1:] if not a.startswith('--')]
# --packages: export only ServerScriptService.Root.Packages (for package-only repos)
PACKAGES_ONLY = '--packages' in sys.argv
tree = json.load(open(ARGS[0]))
out = ARGS[1]
NAME = ARGS[2] if len(ARGS) > 2 else 'game'

children = defaultdict(list)
for k, v in tree.items():
    children[v['parent']].append(int(k))
def node(k): return tree[str(k)]
def name(k): return node(k)['props'].get('Name', '?')
def cls(k): return node(k)['ClassName']

SCRIPTS = {'Script', 'LocalScript', 'ModuleScript'}
SERVICES = ['ServerScriptService', 'ReplicatedStorage', 'ServerStorage',
            'StarterPack', 'StarterGui', 'Workspace', 'TestService']
RUNCTX = {0: None, 1: 'Server', 2: 'Client', 3: 'Plugin'}

needed = set()
for k, v in tree.items():
    if v['ClassName'] in SCRIPTS:
        k = int(k)
        while k is not None:
            needed.add(k); k = node(k)['parent']

WIN_BAD = re.compile(r'[<>:"/\\|?*\x00-\x1f]')
RESERVED = {'CON', 'PRN', 'AUX', 'NUL', *(f'COM{i}' for i in range(1, 10)), *(f'LPT{i}' for i in range(1, 10))}
report = {'renamed': [], 'disabled': [], 'runcontext': [], 'protected_dirs': 0}

def safe(n):
    s = WIN_BAD.sub('_', n).rstrip(' .')
    if not s: s = '_'
    if s.split('.')[0].upper() in RESERVED: s = '_' + s
    if s.lower() == 'init' or s.lower().startswith('init.'): s = '_' + s
    return s

def full(k):
    parts = []
    while k is not None:
        parts.append(name(k)); k = node(k)['parent']
    return '.'.join(reversed(parts))

def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8', newline='') as f:
        f.write(text)

def script_suffix(k):
    return {'Script': '.server.luau', 'LocalScript': '.client.luau', 'ModuleScript': '.luau'}[cls(k)]

def meta_for(k, has_unknown):
    m = {}
    props = {}
    if cls(k) in SCRIPTS:
        p = node(k)['props']
        if p.get('Disabled'):
            props['Disabled'] = True; report['disabled'].append(full(k))
        rc = RUNCTX.get(p.get('RunContext', 0))
        if cls(k) == 'Script' and rc:
            props['RunContext'] = rc; report['runcontext'].append(f'{full(k)} -> {rc}')
    elif cls(k) != 'Folder':
        m['className'] = cls(k)
    if props: m['properties'] = props
    if has_unknown:
        m['ignoreUnknownInstances'] = True; report['protected_dirs'] += 1
    return m

def sig(k, p=''):
    out = []
    if cls(k) in SCRIPTS:
        out.append((p, cls(k), node(k)['props']['Source'], node(k)['props'].get('Disabled')))
    for c in children.get(k, []):
        out += sig(c, p + '/' + name(c))
    return sorted(out)

report['clones'] = []
def dedupe(kids):
    """Same-named siblings with identical scripts are UI template clones; keep one."""
    keep, seen = [], {}
    for c in sorted(kids, key=lambda c: (name(c).lower(), c)):
        n = name(c)
        if n in seen and sig(c) == sig(seen[n][0]):
            seen[n].append(c); continue
        seen.setdefault(n, [c]); keep.append(c)
    for n, ks in seen.items():
        if len(ks) > 1:
            report['clones'].append((full(ks[0]), len(ks)))
    return keep

def emit(k, dirpath, taken):
    """Write instance k into directory dirpath. taken = lowercase names used."""
    base = safe(name(k)); cand = base; i = 2
    while cand.lower() in taken:
        cand = f'{base} ({i})'; i += 1
    taken.add(cand.lower())
    if cand != name(k):
        report['renamed'].append(f'{full(k)}  ->  file name "{cand}"')
    kids = children.get(k, [])
    needed_kids = [c for c in kids if c in needed]
    has_unknown = any(c not in needed for c in kids)
    meta = meta_for(k, has_unknown)
    is_script = cls(k) in SCRIPTS
    if is_script and not needed_kids:
        write(os.path.join(dirpath, cand + script_suffix(k)), node(k)['props']['Source'])
        if meta:
            write(os.path.join(dirpath, cand + '.meta.json'), json.dumps(meta, indent=2) + '\n')
        return
    d = os.path.join(dirpath, cand)
    os.makedirs(d, exist_ok=True)
    sub = {'init'}  # reserve
    if is_script:
        write(os.path.join(d, 'init' + script_suffix(k)), node(k)['props']['Source'])
    if meta:
        write(os.path.join(d, 'init.meta.json'), json.dumps(meta, indent=2) + '\n')
    for c in dedupe(needed_kids):
        emit(c, d, sub)

roots = {name(k): k for k in children[None]}
project = {'name': NAME, 'tree': {'$className': 'DataModel'}}

def child_named(k, n):
    m = [c for c in children[k] if name(c) == n]
    assert len(m) == 1, (n, len(m))
    return m[0]

if PACKAGES_ONLY:
    pk = child_named(child_named(roots['ServerScriptService'], 'Root'), 'Packages')
    d = os.path.join(out, 'src', 'Packages')
    os.makedirs(d, exist_ok=True)
    taken = {'init'}
    for c in dedupe([c for c in children[pk] if c in needed]):
        emit(c, d, taken)
    project['tree']['ServerScriptService'] = {
        '$className': 'ServerScriptService', '$ignoreUnknownInstances': True,
        'Root': {
            '$className': 'Script', '$ignoreUnknownInstances': True,
            'Packages': {'$className': 'Folder', '$path': 'src/Packages', '$ignoreUnknownInstances': True},
        },
    }
    SERVICES = []

for svc in SERVICES:
    if svc not in roots or roots[svc] not in needed: continue
    k = roots[svc]
    d = os.path.join(out, 'src', svc)
    os.makedirs(d, exist_ok=True)
    taken = {'init'}
    for c in dedupe([c for c in children[k] if c in needed]):
        emit(c, d, taken)
    project['tree'][svc] = {'$className': svc, '$path': f'src/{svc}', '$ignoreUnknownInstances': True}
if not PACKAGES_ONLY:
    leftover = [s for s in roots if roots[s] in needed and s not in SERVICES]
    assert not leftover, leftover

write(os.path.join(out, 'default.project.json'), json.dumps(project, indent=2) + '\n')
json.dump(report, open(ARGS[0] + '.report.json', 'w'), indent=1)
print('renamed', len(report['renamed'])); print(*report['renamed'][:30], sep='\n')
print('disabled', len(report['disabled'])); print(*report['disabled'], sep='\n')
print('runcontext', report['runcontext'])
print('protected dirs/scripts', report['protected_dirs'])
