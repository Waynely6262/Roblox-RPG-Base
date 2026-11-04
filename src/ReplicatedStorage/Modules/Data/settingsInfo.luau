return {
	CameraShake = {
		display = "Camera Shake";
		order = 1;
		type = "boolean";
	};
	Sound = {
		display = "Sound Volume";
		order = 2;
		type = "slider";
	};
	Music = {
		display = "Music Volume";
		order = 3;
		type = "slider";
	};
}:: {[string]: {
	display: string;
	order: number;
	type: "slider" | "boolean"
}}