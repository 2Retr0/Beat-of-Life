using Godot;
using System;

[GlobalClass]
public partial class BeatmapPlayer : Node
{
	[Export]
	public AudioStreamPlayer AudioPlayer { get; private set; }

	[Export]
	public BeatmapCSharp BeatmapCSharp { get; private set; }

	[Export]
	public double CurrentTime { get; private set; }

	public virtual void Initialize(BeatmapCSharp beatmap)
	{
		BeatmapCSharp = beatmap;
		AudioPlayer.Stream = BeatmapCSharp.Audio;
	}

	public virtual void Play()
	{
		AudioPlayer.Play();
	}

	public override void _Process(double delta)
	{
		CurrentTime = Math.Max(CurrentTime, AudioPlayer.GetPlaybackPosition() + AudioServer.GetTimeSinceLastMix());
	}

	protected virtual PlayableObject CreatePlayable(HitObject hitObject)
	{
		throw new NotImplementedException();
	}
}
