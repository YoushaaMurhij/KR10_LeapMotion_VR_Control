// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Chris/Skin"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (0,0,0,0)
		_Normal("Normal", 2D) = "bump" {}
		_SpecularGlossinessAO("SpecularGlossinessAO", 2D) = "white" {}
		_SpecularColor("SpecularColor", Color) = (0,0,0,0)
		_SpecularIntensity("SpecularIntensity", Range( 0 , 1)) = 0.1854285
		_Glossiness("Glossiness", Range( 0.01 , 1)) = 0.01
		_GlossinessFalloff("GlossinessFalloff", Range( 0.01 , 1)) = 1
		_AOIntensity("AOIntensity", Range( 0 , 1)) = 0
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_Detail("Detail", 2D) = "white" {}
		_NormalScale("NormalScale", Range( 0 , 10)) = 0
		_DetailNormal("DetailNormal", 2D) = "bump" {}
		_DetailNormalScale("DetailNormalScale", Range( 0 , 10)) = 0
		_TranslucencyTex("TranslucencyTex", 2D) = "white" {}
		_TranslucencyColor("TranslucencyColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 4.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float3 worldRefl;
		};

		struct SurfaceOutputStandardSpecularCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Specular;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
			half3 Translucency;
		};

		uniform float _NormalScale;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _DetailNormalScale;
		uniform sampler2D _DetailNormal;
		uniform float4 _DetailNormal_ST;
		uniform sampler2D _Detail;
		uniform float4 _Detail_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _BaseColor;
		uniform float4 _SpecularColor;
		uniform sampler2D _SpecularGlossinessAO;
		uniform float4 _SpecularGlossinessAO_ST;
		uniform float _SpecularIntensity;
		uniform float _Glossiness;
		uniform float _GlossinessFalloff;
		uniform float _AOIntensity;
		uniform sampler2D _TranslucencyTex;
		uniform float4 _TranslucencyTex_ST;
		uniform float4 _TranslucencyColor;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;

		inline half4 LightingStandardSpecularCustom(SurfaceOutputStandardSpecularCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandardSpecular r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Specular = s.Specular;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandardSpecular (r, viewDir, gi) + c + d;
		}

		inline void LightingStandardSpecularCustom_GI(SurfaceOutputStandardSpecularCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardSpecularCustom o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 tex2DNode7 = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale );
			float2 uv_DetailNormal = i.uv_texcoord * _DetailNormal_ST.xy + _DetailNormal_ST.zw;
			o.Normal = BlendNormals( tex2DNode7 , UnpackScaleNormal( tex2D( _DetailNormal, uv_DetailNormal ), _DetailNormalScale ) );
			float2 uv_Detail = i.uv_texcoord * _Detail_ST.xy + _Detail_ST.zw;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 blendOpSrc67 = tex2D( _Detail, uv_Detail );
			float4 blendOpDest67 = ( tex2D( _Albedo, uv_Albedo ) * _BaseColor );
			o.Albedo = ( saturate( ( blendOpSrc67 * blendOpDest67 ) )).rgb;
			float2 uv_SpecularGlossinessAO = i.uv_texcoord * _SpecularGlossinessAO_ST.xy + _SpecularGlossinessAO_ST.zw;
			float4 tex2DNode12 = tex2D( _SpecularGlossinessAO, uv_SpecularGlossinessAO );
			float lerpResult24 = lerp( 0.0 , 2.0 , _SpecularIntensity);
			float4 temp_output_27_0 = ( _SpecularColor * tex2DNode12.r * lerpResult24 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult47 = dot( ase_worldTangent , ase_worldViewDir );
			float clampResult48 = clamp( dotResult47 , 0.0 , 1.0 );
			float dotResult53 = dot( tex2DNode7 , ase_worldTangent );
			float clampResult54 = clamp( dotResult53 , 0.0 , 1.0 );
			float4 lerpResult51 = lerp( temp_output_27_0 , ( temp_output_27_0 * clampResult48 ) , clampResult54);
			o.Specular = lerpResult51.rgb;
			float dotResult57 = dot( ase_worldViewDir , WorldReflectionVector( i , tex2DNode7 ) );
			float clampResult58 = clamp( dotResult57 , 0.0 , 1.0 );
			o.Smoothness = pow( ( tex2DNode12.g * _Glossiness * clampResult58 ) , ( 1.0 - _GlossinessFalloff ) );
			o.Occlusion = ( tex2DNode12.b * _AOIntensity );
			float2 uv_TranslucencyTex = i.uv_texcoord * _TranslucencyTex_ST.xy + _TranslucencyTex_ST.zw;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 temp_output_6_0 = ( tex2D( _TranslucencyTex, uv_TranslucencyTex ) * _TranslucencyColor * ase_lightColor );
			o.Transmission = temp_output_6_0.rgb;
			o.Translucency = temp_output_6_0.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecularCustom keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardSpecularCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecularCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16200
7;29;1906;1004;845.085;581.5438;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;62;-2192.745,-29.32936;Float;False;Property;_NormalScale;NormalScale;17;0;Create;True;0;0;False;0;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-1833.83,-85.1133;Float;True;Property;_Normal;Normal;2;0;Create;True;0;0;False;0;None;a9da07e90b50d29449b0e86a7d4e3c13;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-1040.468,558.6481;Float;False;Constant;_SpecIntMax;SpecIntMax;12;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1043.629,635.6503;Float;False;Property;_SpecularIntensity;SpecularIntensity;5;0;Create;True;0;0;False;0;0.1854285;0.211;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexTangentNode;45;-1832.376,839.1209;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;25;-1043.168,478.4482;Float;False;Constant;_SpecIntMin;SpecIntMin;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;46;-1837.161,1136.206;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldReflectionVector;56;-1644.501,1464.285;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;12;-1049.876,263.4523;Float;True;Property;_SpecularGlossinessAO;SpecularGlossinessAO;3;0;Create;True;0;0;False;0;None;c9c122847219ba34aa440cccb1468fa0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;57;-1433.038,1275.209;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;47;-1425.967,840.2546;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;-1046.323,85.85379;Float;False;Property;_SpecularColor;SpecularColor;4;0;Create;True;0;0;False;0;0,0,0,0;1,0.9267749,0.8602941,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;24;-722.4682,485.6482;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-735.7491,775.8776;Float;False;Property;_Glossiness;Glossiness;6;0;Create;True;0;0;False;0;0.01;0.587;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2252.665,-227.5233;Float;False;Property;_DetailNormalScale;DetailNormalScale;19;0;Create;True;0;0;False;0;0;0.7;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;48;-1209.014,838.0232;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-369.4854,983.8961;Float;False;Property;_GlossinessFalloff;GlossinessFalloff;7;0;Create;True;0;0;False;0;1;0.526;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;53;-1417.903,1068.597;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-484.8145,-382.3465;Float;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;None;699a94a5ea3ba86488d2e56c6d8d6a16;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-483.2902,-163.3947;Float;False;Property;_BaseColor;BaseColor;1;0;Create;True;0;0;False;0;0,0,0,0;1,0.9666329,0.9485294,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-465.5868,248.0207;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;58;-1199.223,1273.171;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;63;-1800.967,-304.3427;Float;True;Property;_DetailNormal;DetailNormal;18;0;Create;True;0;0;False;0;None;fc38c1fdfea54a547983970ebab074da;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-471.0027,1409.915;Float;True;Property;_TranslucencyTex;TranslucencyTex;20;0;Create;True;0;0;False;0;None;fcc6c96a9481d7640860808675315acf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-384.8671,1149.989;Float;False;Property;_AOIntensity;AOIntensity;8;0;Create;True;0;0;False;0;0;0.543;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;54;-1199.791,1066.537;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;11;-457.4799,1827.902;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;5;-465.0027,1626.915;Float;False;Property;_TranslucencyColor;TranslucencyColor;21;0;Create;True;0;0;False;0;0,0,0,0;0.7941176,0.3378624,0.1518165,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-106.121,-196.8953;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;66;-496.35,-619.2131;Float;True;Property;_Detail;Detail;16;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;59;-55.20292,961.7869;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-130.5255,391.4076;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-45.89437,726.205;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;67;479.65,-391.2131;Float;False;Multiply;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-135.156,1681.066;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;44;189.7638,768.463;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;335.0358,322.1318;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;121.3734,1086.061;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;65;-1123.42,-338.1432;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;922.1005,255.6928;Float;False;True;4;Float;ASEMaterialInspector;0;0;StandardSpecular;Chris/Skin;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;9;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;5;62;0
WireConnection;56;0;7;0
WireConnection;57;0;46;0
WireConnection;57;1;56;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;24;0;25;0
WireConnection;24;1;26;0
WireConnection;24;2;23;0
WireConnection;48;0;47;0
WireConnection;53;0;7;0
WireConnection;53;1;45;0
WireConnection;27;0;22;0
WireConnection;27;1;12;1
WireConnection;27;2;24;0
WireConnection;58;0;57;0
WireConnection;63;5;64;0
WireConnection;54;0;53;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;59;0;30;0
WireConnection;49;0;27;0
WireConnection;49;1;48;0
WireConnection;15;0;12;2
WireConnection;15;1;13;0
WireConnection;15;2;58;0
WireConnection;67;0;66;0
WireConnection;67;1;3;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;6;2;11;0
WireConnection;44;0;15;0
WireConnection;44;1;59;0
WireConnection;51;0;27;0
WireConnection;51;1;49;0
WireConnection;51;2;54;0
WireConnection;61;0;12;3
WireConnection;61;1;60;0
WireConnection;65;0;7;0
WireConnection;65;1;63;0
WireConnection;0;0;67;0
WireConnection;0;1;65;0
WireConnection;0;3;51;0
WireConnection;0;4;44;0
WireConnection;0;5;61;0
WireConnection;0;6;6;0
WireConnection;0;7;6;0
ASEEND*/
//CHKSM=B57B433EFD137E0205B3276531FA5DD02F06274E