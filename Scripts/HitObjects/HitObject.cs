using Godot;
using System;

public partial class HitObject(double time, int keyId) : GodotObject
{
	public double Time { get; private set; } = time;
	public int KeyId { get; private set; } = keyId;
}
