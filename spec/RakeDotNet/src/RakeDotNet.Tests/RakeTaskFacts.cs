using Xunit;

namespace RakeDotNet.Tests
{
    public class RakeTaskFacts
    {
        [Fact]
        public void WhenTraceIsSetShouldBePresentInCommand()
        {
            var rt = new FakeRakeTask {Trace = true};
            var cmd = rt.GenerateCommandLineArguments();
            Assert.Contains(" -t", cmd);
        }

        [Fact]
        public void WhenVerboseIsSpecifiedShouldBePresentInCommand()
        {
            var rt = new FakeRakeTask {Verbose = true};
            var cmd = rt.GenerateCommandLineArguments();
            Assert.Contains(" VERBOSE=true", cmd);
        }

        [Fact]
        public void WhenTasksAreSpecifiedShouldBePresentInCommand()
        {
            var rt = new FakeRakeTask {Tasks = "assembly_info foo"};
            var cmd = rt.GenerateCommandLineArguments();
            Assert.Contains(" assembly_info foo", cmd);
        }

        #region Nested type: FakeRakeTask

        private class FakeRakeTask : RakeTask
        {
            public string GenerateCommandLineArguments()
            {
                return base.GenerateCommandLineCommands();
            }
        }

        #endregion
    }
}