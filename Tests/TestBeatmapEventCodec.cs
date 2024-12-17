using Godot;
using System;

public partial class TestBeatmapEventCodec : BeatmapEventCodec
{
	public override string Encode(BeatmapEvent beatmapEvent)
	{
		return string.Empty;
	}
	
	public override BeatmapEvent Decode(string str)
	{
		return new(double.Parse(str));
	}
}
