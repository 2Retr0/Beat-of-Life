using Godot;
using System;
using System.Collections.Generic;

public partial class BeatmapLoaderTest : Node
{
	public override void _Ready()
	{
		List<Ruleset> rulesets = [
			new(0, new TestHitObjectCodec(), new TestBeatmapEventCodec()),
			new(1, new TestHitObjectCodec(), new TestBeatmapEventCodec())
		];
		
		string resPath = Godot.ProjectSettings.GlobalizePath("res://");
		
		string path0 = $"{resPath}Tests/test0.txt";
		Beatmap beatmap0 = BeatmapLoader.Load(rulesets, new(path0));
		
		GD.Print(beatmap0.Ruleset.RulesetId);
		GD.Print(beatmap0.HitObjects.Count);
		GD.Print(beatmap0.Events.Count);
		
		string path1 = $"{resPath}Tests/test1.txt";
		Beatmap beatmap1 = BeatmapLoader.Load(rulesets, new(path1));
		
		GD.Print(beatmap1.Ruleset.RulesetId);
		GD.Print(beatmap1.HitObjects.Count);
		GD.Print(beatmap1.Events.Count);
	}
}
