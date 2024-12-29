using Godot;
using System;

[GlobalClass]
public partial class RhythmHitObject : HitObject
{
	[Export]
	public int Beats { get; private set; }
}
