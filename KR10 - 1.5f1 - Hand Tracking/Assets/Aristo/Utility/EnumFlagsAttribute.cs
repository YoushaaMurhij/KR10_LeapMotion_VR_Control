using UnityEngine;
using System.Collections;

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEditor;

namespace ViveHandTracking {

[CustomPropertyDrawer(typeof(EnumFlagsAttribute))]
class EnumFlagsAttributeDrawer : PropertyDrawer {
  public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
    var attribute = fieldInfo.GetCustomAttributes(typeof(TooltipAttribute), true).FirstOrDefault() as TooltipAttribute;
    if (attribute != null)
      label.tooltip = attribute.tooltip;
    property.intValue = EditorGUI.MaskField(position, label, property.intValue, property.enumNames);
  }
}

}

#endif

namespace ViveHandTracking {

class EnumFlagsAttribute : PropertyAttribute {
  public EnumFlagsAttribute() {}
}

}
