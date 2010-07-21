using System;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.Build.Utilities;

namespace RakeDotNet
{
    public class RakeTask : ToolTask
    {
        protected override string ToolName
        {
            get { return "rake.bat"; }
        }

        public string Tasks { get; set; }

        public bool Verbose { get; set; }

        public bool Trace { get; set; }

        protected override string GenerateFullPathToTool()
        {
            if (string.IsNullOrEmpty(ToolPath))
                ToolPath = FindToolPath(ToolName);

            return Path.Combine(ToolPath, ToolName);
        }

        protected override string GenerateCommandLineCommands()
        {
            var cmd = new StringBuilder(GenerateFullPathToTool());
            if (Trace) cmd.Append(" -t");
            if (Verbose) cmd.Append(" VERBOSE=true");
            cmd.Append(" ").Append(Tasks);
            return cmd.ToString();
        }

        public static string FindToolPath(string toolName)
        {
            string toolPath = null;

            var pathEnvironmentVariable = Environment.GetEnvironmentVariable("PATH") ?? string.Empty;
            var paths =
                pathEnvironmentVariable.Split(new[] {Path.PathSeparator}, StringSplitOptions.RemoveEmptyEntries).Where(
                    x => x.ToLower().Contains("ruby")).ToArray();
            foreach (var path in paths)
            {
                var fullPathToClient = Path.Combine(path, toolName);
                if (SafeFileExists(fullPathToClient))
                {
                    toolPath = path;
                    break;
                }
            }

            // try some typical locations
            string[] locations = {
                                     Path.Combine(Path.Combine("c:", "ruby"), "bin"),
                                     Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles),
                                                  @"ruby\bin")
                                 };
            foreach (var path in locations)
            {
                var fullPathToClient = Path.Combine(path, toolName);
                if (SafeFileExists(fullPathToClient))
                {
                    toolPath = path;
                    break;
                }
            }

            if (toolPath == null)
            {
                throw new Exception(
                    "Could not find rake.  Looked in PATH locations and various common folders.");
            }

            return toolPath;
        }

        private static bool SafeFileExists(string file)
        {
            try
            {
                return File.Exists(file);
            }
            catch
            {
            } // eat exception

            return false;
        }
    }
}