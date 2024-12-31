using Godot;
using System;

[GlobalClass]
public partial class RhythmPlayableObject : PlayableObject
{
	public override void _Ready()
	{
	}

	public override void _Process(double delta)
	{
		double scrollSpeed = (Player as RhythmBeatmapPlayer).ScrollSpeed;
		//Translation = new Vector2((Player.CurrentTime - HitObject.Time) * scrollSpeed, 0);
	}
}
