using Godot;
using System;

public abstract partial class BeatmapEventCodec : GodotObject
{
	public abstract string Encode(BeatmapEvent beatmapEvent);
	
	public abstract BeatmapEvent Decode(string str);
}
