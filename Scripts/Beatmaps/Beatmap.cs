using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Beatmap(Ruleset ruleset,
	IEnumerable<HitObject> hitObjects,
	IEnumerable<BeatmapEvent> events) : GodotObject
{
	public Ruleset Ruleset { get; private set; } = ruleset;
	public List<HitObject> HitObjects { get; private set; } = hitObjects.ToList();
	public List<BeatmapEvent> Events { get; private set; } = events.ToList();
}
