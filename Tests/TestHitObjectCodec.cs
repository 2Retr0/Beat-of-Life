using Godot;
using System;

public partial class TestHitObjectCodec : HitObjectCodec
{
	public override string Encode(HitObject hitObject)
	{
		return string.Empty;
	}
	
	public override HitObject Decode(string str)
	{
		string[] subs = str.Split(',');
		return new(double.Parse(subs[0]), int.Parse(subs[1]));
	}
}
