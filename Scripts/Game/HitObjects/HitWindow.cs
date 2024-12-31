using Godot;
using System;

[GlobalClass]
public partial class HitWindow : GodotObject
{
	[Export]
	public HitResult Result { get; private set; }

	[Export]
	public double Range { get; private set; }

	public HitWindow()
	{
	}

	public HitWindow(HitResult result, double range)
	{
		Result = result;
		Range = range;
	}
}
