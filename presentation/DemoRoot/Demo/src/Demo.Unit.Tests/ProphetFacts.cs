using Xunit;

namespace Demo.Unit.Tests
{
	public class ProphetFacts
	{
		[Fact]
		public void ProphetCanPreach()
		{
			var prophet = new Prophet();
			Assert.DoesNotThrow(prophet.Preach);
		}
	}
}