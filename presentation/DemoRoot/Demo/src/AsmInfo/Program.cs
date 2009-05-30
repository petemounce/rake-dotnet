using System;
using System.IO;
using System.Reflection;

namespace AsmInfo
{
	internal class Program
	{
		private static void Main(string[] args)
		{
			if (args.Length != 1 || string.IsNullOrEmpty(args[0]))
			{
				Console.WriteLine(@"Usage: AsmInfo {relative-path-to-dll}");
				return;
			}
			var asmRelPath = args[0].Trim();
			var asmAbsPath = Environment.CurrentDirectory + Path.DirectorySeparatorChar + asmRelPath;
			var asmFile = Assembly.LoadFile(asmAbsPath);
			Console.WriteLine(asmFile.GetName().Version.ToString(4));
		}
	}
}