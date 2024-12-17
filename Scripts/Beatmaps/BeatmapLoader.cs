using Godot;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

public partial class BeatmapLoader : GodotObject
{
	public const string MetadataHeader = "#Metadata";
	public const string ObjectsHeader = "#Objects";
	public const string EventsHeader = "#Events";
	
	public const string RulesetIdKey = "RulesetId";
	
	public static Beatmap Load(List<Ruleset> rulesets, FileInfo file)
	{
		if(!file.Exists)
		{
			return null;
		}
		
		List<string> lines = File.ReadAllLines(file.FullName)
			.Select(line => new string(line.Where(c => !char.IsWhiteSpace(c)).ToArray())) // Remove whitespaces
			.ToList();
		
		Dictionary<string, string> metadata = TakeLines(lines, MetadataHeader)
			.Select(line => line.Split(':'))
			.GroupBy(subs => subs[0])
			.ToDictionary(group => group.Key, group => group.First().Skip(1).First());
		
		int rulesetId = int.Parse(metadata[RulesetIdKey]);
		Ruleset ruleset = rulesets.First(ruleset => ruleset.RulesetId == rulesetId);
		
		List<HitObject> hitObjects = TakeLines(lines, ObjectsHeader)
			.Select(line => ruleset.HitObjectCodec.Decode(line))
			.ToList();
		
		List<BeatmapEvent> events = TakeLines(lines, EventsHeader)
			.Select(line => ruleset.BeatmapEventCodec.Decode(line))
			.ToList();
		
		return new(ruleset, hitObjects, events);
	}
	
	public static List<string> TakeLines(List<string> lines, string header) {
		return lines.SkipWhile(line => line != header)
			.Skip(1) // Skip the header line itself
			.TakeWhile(line => !IsHeader(line)) // Take until the next header or EOF
			.Where(line => !string.IsNullOrEmpty(line)) // Remove empty lines
			.ToList();
	}
	
	public static bool IsHeader(string str)
	{
		return str.Trim().StartsWith("#");
	}
}
