using Godot;
using System;

[GlobalClass]
public partial class HitObject : Resource
{
	[Export]
	public double Time { get; private set; }

	public virtual HitWindows DefaultHitWindows => throw new NotImplementedException();

	public HitObject()
	{
	}

	public HitObject(double time)
	{
		Time = time;
	}
}
