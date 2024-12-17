using Godot;
using System;

public abstract partial class HitObjectCodec : GodotObject
{
	public abstract string Encode(HitObject hitObject);
	
	public abstract HitObject Decode(string str);
}
