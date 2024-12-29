using Godot;
using System;

[GlobalClass]
public partial class Ruleset : Resource
{
	[Export(PropertyHint.File, "*.tscn")]
	public string ScenePath { get; private set; } = string.Empty;
	
	public BeatmapPlayer CreatePlayer(Node parent, Beatmap beatmap)
	{
		PackedScene scene = GD.Load<PackedScene>(ScenePath);
		
		BeatmapPlayer player = scene.Instantiate() as BeatmapPlayer;
		parent.AddChild(player);
		
		player.Initialize(beatmap);
		
		return player;
	}
}
