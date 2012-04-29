using System;
using System.Collections.Generic;
using System.Reflection;
using CyclopsFramework.Core;
using CyclopsFramework.Core.Easing;

namespace CyclopsFramework.Actions.Interpolation
{

	public class CFInterpolate1F:CFAction
    {
        public const string TAG = "@CFInterpolate1F";
		
		object _targetObject;
        IEnumerable<string> _targetTags;
		string _propertyName;
		float _value1;
		float _value2;
		PropertyInfo _pinfo;
        FieldInfo _finfo;
		
        public CFInterpolate1F(
		    object targetObject,
            string propertyName,
		    float value1,
		    float value2,
		    float period,
		    float cycles,
		    CFBias.FofT bias)
            :base(period, cycles, bias, TAG)
        {
			_targetObject = targetObject;
			_propertyName = propertyName;
			_value1 = value1;
			_value2 = value2;
			_pinfo = _targetObject.GetType().GetProperty(_propertyName);
            _finfo = _targetObject.GetType().GetField(_propertyName);
		}

        public CFInterpolate1F(
            string targetTag,
            string propertyName,
            float value1,
            float value2,
            float period,
            float cycles,
            CFBias.FofT bias)
            : base(period, cycles, bias, TAG)
        {
            _targetTags = new[] {targetTag};
            _propertyName = propertyName;
            _value1 = value1;
            _value2 = value2;
        }

        public CFInterpolate1F(
            IEnumerable<string> targetTags,
            string propertyName,
            float value1,
            float value2,
            float period,
            float cycles,
            CFBias.FofT bias)
            : base(period, cycles, bias, TAG)
        {
            _targetTags = targetTags;
            _propertyName = propertyName;
            _value1 = value1;
            _value2 = value2;
        }
		
		protected override void OnFrame(float t)
		{
            if (_targetTags != null)
            {
                foreach (ICFTaggable item in Engine.Filter(_targetTags))
                {
                    var finfo = item.GetType().GetField(_propertyName);
                    if (finfo != null)
                    {
                        finfo.SetValue(item, _value1 + (_value2 - _value1) * t);
                    }
                    else
                    {
                        var pinfo = item.GetType().GetProperty(_propertyName);
                        if (pinfo != null)
                        {
                            pinfo.SetValue(item, _value1 + (_value2 - _value1) * t, null);
                        }
                    }
                }
            }
            else if (_finfo != null)
            {
                _finfo.SetValue(_targetObject, _value1 + (_value2 - _value1) * t);
            }
            else
            {
                _pinfo.SetValue(_targetObject, _value1 + (_value2 - _value1) * t, null);
            }
        }

    }
}
