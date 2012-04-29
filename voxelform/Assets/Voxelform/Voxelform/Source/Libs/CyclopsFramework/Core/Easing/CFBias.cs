using System;
using System.Collections.Generic;
using System.Text;

namespace CyclopsFramework.Core.Easing
{
    public class CFBias
    {
		public delegate float FofT(float t);
		
		public static float Linear(float t)
		{
			return t;
		}
		
		public static float Reverse(float t)
		{
			return (1.0f - t);
		}
		
		public static float EaseIn(float t)
		{
			return (t * t * t);
		}
		
		public static float EaseOut(float t)
		{
			return ((t - 1.0f) * (t - 1.0f) * (t - 1.0f) + 1.0f);
		}
		
		public static float EaseInOut(float t)
		{
			return (((t /= 0.5f) < 1.0f) ? ((t * t * t) * 0.5f) : (((t - 2.0f) * (t - 2.0f) * (t - 2.0f) + 2.0f) * 0.5f));
		}
		
		public static float EaseSineWaveIn(float t)
		{
			return ((1.0f - (float)Math.Cos(t * Math.PI / 2.0f)));
		}
		
		public static float EaseSineWaveOut(float t)
		{
			return ((float)(Math.Sin(t * Math.PI / 2.0f)));
		}
		
		public static float EaseSineWaveInOut(float t)
		{
			return ((1.0f - (float)Math.Cos(Math.PI * t)) / 2.0f);
		}
		
		public static float EaseExpIn(float t)
		{
			return ((float)Math.Pow(2f, 10.0f * (t - 1.0f)));
		}
		
		public static float EaseExpOut(float t)
		{
			return ((float)Math.Pow(2.0f, -10.0f * t) + 1.0f);
		}
		
		public static float EaseExpInOut(float t)
		{
			return (float)((((t /= 0.5f) < 1.0f) ? (Math.Pow(2.0f, 10.0f * (t - 1.0f)) / 2.0f) : (-Math.Pow(2.0f, -10.0f * (t - 1.0f)) + 2.0f) / 2.0f));
		}
		
		public static float EaseElasticIn(float t)
		{
			return (float)(-(Math.Pow(2.0f, 10.0f * (t - 1.0f)) * Math.Sin((t - 0.75f) * (Math.PI * 2.0f) / 0.3f)));
		}
		
		public static float EaseElasticOut(float t)
		{
			return (float)(t + ((1.0f / (t * t * t)) * Math.Sin(t * t * t * Math.PI * 8.0f)));
		}
		
		public static float FlatTop(float t)
		{
			return (1.0f);
		}
		
		public static float FlatMiddle(float t)
		{
			return (0.5f);
		}
		
		public static float FlatBottom(float t)
		{
			return (0.0f);
		}
		
		public static float Noise(float t)
		{
			return UnityEngine.Random.value;
		}
		
		public static float SawtoothWave(float t)
		{
			return ((t <= 0.5f) ? (t * 2.0f) : (2.0f - t * 2.0f));
		}
		
		public static float SquareWave(float t)
		{
			return ((t < 0.5f) ? 0.0f : 1.0f);
		}
		
		public static float SineWave(float t)
		{
			return (0.5f + (float)Math.Sin((t*2.0f-0.5f) * Math.PI) * 0.5f);
		}

    }
}
