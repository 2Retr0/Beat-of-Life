using Godot;
using System;

public partial class BeatmapEvent(double time) : GodotObject
{
	public double Time { get; private set; } = time;
}
