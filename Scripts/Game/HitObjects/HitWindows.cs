using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

[GlobalClass]
public partial class HitWindows(List<HitWindow> windows) : GodotObject
{
	public List<HitWindow> Windows { get; private set; } = windows;
	
	[Export]
	public Godot.Collections.Array<HitWindow> WindowsGD
	{
		get => new Godot.Collections.Array<HitWindow>(Windows);
		set => Windows = value.ToList();
	}
	
	public HitResult GetHitResult(double delta)
	{
		return Windows.OrderBy(window => window.Range)
			.FirstOrDefault(window => Math.Abs(delta) <= window.Range)?.Result ?? HitResult.None;
	}
}
