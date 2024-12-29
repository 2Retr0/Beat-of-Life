using Godot;
using System;

[GlobalClass]
public partial class BeatmapEvent : Resource
{
	[Export]
	public double Time { get; private set; }
	
	public BeatmapEvent()
	{
	}
	
	public BeatmapEvent(double time)
	{
		Time = time;
	}
}
