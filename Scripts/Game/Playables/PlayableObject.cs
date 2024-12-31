using Godot;
using System;

[GlobalClass]
public partial class PlayableObject : Node2D
{
	[Export]
	public BeatmapPlayer Player { get; private set; }

	[Export]
	public HitObject HitObject { get; private set; }

	public void Initialize(BeatmapPlayer player, HitObject hitObject)
	{
		Player = player;
		HitObject = hitObject;
	}
}
