using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;

[GlobalClass]
public partial class Beatmap : Resource
{
	public const double DefaultBpm = 60;
	
	[Export]
	public Ruleset Ruleset { get; private set; }
	
	[Export]
	public AudioStream Audio { get; private set; }
	
	public List<HitObject> HitObjects { get; private set; } = new();
	
	[Export]
	public Godot.Collections.Array<HitObject> HitObjectsGD
	{
		get => new Godot.Collections.Array<HitObject>(HitObjects);
		set => HitObjects = value.ToList();
	}
	
	public List<BeatmapEvent> Events { get; private set; } = new();
	
	[Export]
	public Godot.Collections.Array<BeatmapEvent> EventsGD
	{
		get => new Godot.Collections.Array<BeatmapEvent>(Events);
		set => Events = value.ToList();
	}
	
	public Beatmap()
	{
	}
	
	public Beatmap(Ruleset ruleset)
	{
		Ruleset = ruleset;
	}
	
	public virtual double GetBpm(double time)
	{
		return Events.OfType<TimingEvent>().LastOrDefault(evt => evt.Time <= time)?.Bpm ?? DefaultBpm;
	}
}
