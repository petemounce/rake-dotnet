using Demo.Middle;
using Xunit;

namespace Demo.Unit.Tests
{
	public class BarFacts
	{
		[Fact]
		public void WalkIntoFact()
		{
			var bar = new Bar();
			Assert.DoesNotThrow(bar.WalkInto);
		}
	}
}