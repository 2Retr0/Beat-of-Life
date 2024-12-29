using Godot;
using System;

[GlobalClass]
public partial class TimingEvent : BeatmapEvent
{
	[Export]
	public double Bpm { get; private set; }
	
	public TimingEvent()
	{
	}
	
	public TimingEvent(double time, double bpm) : base(time)
	{
		Bpm = bpm;
	}
}
