"""Minimal Roblox binary place (.rbxl) parser: extracts the instance tree,
Name/ClassName, and script Source/RunContext/Disabled properties."""
import struct, sys, json
import lz4.block, zstandard

def read_chunks(data):
    assert data[:8] == b'<roblox!'
    n_classes, n_inst = struct.unpack_from('<ii', data, 16)
    pos = 32
    while pos < len(data):
        name = data[pos:pos+4]; comp, uncomp, _ = struct.unpack_from('<III', data, pos+4)
        pos += 16
        if comp == 0:
            body = data[pos:pos+uncomp]; pos += uncomp
        else:
            raw = data[pos:pos+comp]; pos += comp
            if raw[:4] == b'\x28\xb5\x2f\xfd':
                body = zstandard.ZstdDecompressor().decompress(raw, max_output_size=uncomp)
            else:
                body = lz4.block.decompress(raw, uncompressed_size=uncomp)
        yield name, body
        if name == b'END\x00':
            break

def interleaved_ints(b, off, n):
    raw = bytes(b[off + i + j*n] for i in range(n) for j in range(4))
    out = []
    for i in range(n):
        v = struct.unpack('>I', raw[i*4:i*4+4])[0]
        out.append((v >> 1) ^ -(v & 1))
    return out

def referents(b, off, n):
    vals = interleaved_ints(b, off, n)
    acc, out = 0, []
    for v in vals:
        acc += v; out.append(acc)
    return out

def parse(path):
    data = open(path, 'rb').read()
    classes, inst, sstr = {}, {}, []
    for name, b in read_chunks(data):
        if name == b'SSTR':
            _, count = struct.unpack_from('<II', b, 0); p = 8
            for _ in range(count):
                p += 16; (ln,) = struct.unpack_from('<I', b, p); p += 4
                sstr.append(b[p:p+ln]); p += ln
        elif name == b'INST':
            cid, = struct.unpack_from('<I', b, 0); (ln,) = struct.unpack_from('<I', b, 4)
            cname = b[8:8+ln].decode(); p = 8 + ln
            p += 1  # object format
            (cnt,) = struct.unpack_from('<I', b, p); p += 4
            refs = referents(b, p, cnt)
            classes[cid] = (cname, refs)
            for r in refs:
                inst[r] = {'ClassName': cname, 'props': {}, 'parent': None}
        elif name == b'PROP':
            cid, = struct.unpack_from('<I', b, 0); (ln,) = struct.unpack_from('<I', b, 4)
            pname = b[8:8+ln].decode(); p = 8 + ln
            ptype = b[p]; p += 1
            refs = classes[cid][1]
            if ptype == 0x01 and pname in ('Name', 'Source'):
                for r in refs:
                    (sl,) = struct.unpack_from('<I', b, p); p += 4
                    inst[r]['props'][pname] = b[p:p+sl].decode('utf-8', 'replace'); p += sl
            elif ptype == 0x1C and pname == 'Source':
                # shared-string indices are stored as unsigned, not zigzag
                raw = [struct.unpack('>I', bytes(b[p+i+j*len(refs)] for j in range(4)))[0] for i in range(len(refs))]
                for r, k in zip(refs, raw):
                    inst[r]['props'][pname] = sstr[k].decode('utf-8', 'replace')
            elif ptype == 0x02 and pname == 'Disabled':
                for i, r in enumerate(refs):
                    inst[r]['props'][pname] = bool(b[p+i])
            elif ptype == 0x12 and pname == 'RunContext':
                vals = [struct.unpack('>I', bytes(b[p+i+j*len(refs)] for j in range(4)))[0] for i in range(len(refs))]
                for r, v in zip(refs, vals):
                    inst[r]['props'][pname] = v
        elif name == b'PRNT':
            (cnt,) = struct.unpack_from('<I', b, 1)
            kids = referents(b, 5, cnt); pars = referents(b, 5 + cnt*4, cnt)
            for c, pr in zip(kids, pars):
                inst[c]['parent'] = pr if pr != -1 else None
    return inst

if __name__ == '__main__':
    inst = parse(sys.argv[1])
    out = {str(k): v for k, v in inst.items()}
    json.dump(out, open(sys.argv[2], 'w'))
    from collections import Counter
    print(len(inst), 'instances')
    print(Counter(v['ClassName'] for v in inst.values()).most_common(25))
