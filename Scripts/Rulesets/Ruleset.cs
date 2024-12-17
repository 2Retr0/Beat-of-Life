using Godot;
using System;

public partial class Ruleset(int rulesetId,
	HitObjectCodec hitObjectCodec,
	BeatmapEventCodec beatmapEventCodec) : GodotObject
{
	// TODO replace with strongly typed id
	public int RulesetId { get; private set; } = rulesetId;
	public HitObjectCodec HitObjectCodec { get; private set; } = hitObjectCodec;
	public BeatmapEventCodec BeatmapEventCodec { get; private set; } = beatmapEventCodec;
}
