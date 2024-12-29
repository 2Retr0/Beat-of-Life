using Godot;
using System;

[GlobalClass]
public partial class RhythmBeatmapPlayer : BeatmapPlayer
{
	[Export]
	public Node PlayableRoot { get; private set; }
	
	[Export(PropertyHint.File, "*.tscn")]
	public string RhythmPlayableObjectPath { get; private set; } = string.Empty;
	
	[Export]
	public double ScrollSpeed { get; private set; }
	
	public override void Initialize(Beatmap beatmap)
	{
		base.Initialize(beatmap);
	}
	
	public override void _Process(double delta)
	{
		base._Process(delta);
	}
	
	protected override PlayableObject CreatePlayable(HitObject hitObject)
	{
		PlayableObject playable = hitObject switch
		{
			RhythmHitObject rhythmHitObject => GD.Load<PackedScene>(RhythmPlayableObjectPath).Instantiate() as RhythmPlayableObject,
			_ => null,
		};
		
		if(playable != null)
		{
			PlayableRoot.AddChild(playable);
			
			playable.Initialize(this, hitObject);
		}
		
		return playable;
	}
}
