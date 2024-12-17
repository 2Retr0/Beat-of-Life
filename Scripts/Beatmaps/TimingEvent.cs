using Godot;
using System;

public partial class TimingEvent(double time, double bpm) : BeatmapEvent(time)
{
	public double BPM { get; private set; } = bpm;
}
