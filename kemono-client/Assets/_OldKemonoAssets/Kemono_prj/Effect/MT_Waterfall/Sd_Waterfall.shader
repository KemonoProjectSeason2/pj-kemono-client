// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "waterfall"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_RippSpeed("RippSpeed", Vector) = (0,1.52,0,0)
		_voronoispeed("voronoispeed", Vector) = (2,2,0,0)
		_RipplesAmount("RipplesAmount", Range( -2 , 2)) = 0
		_Refraction("Refraction", Range( 0 , 3)) = 1.03
		_Opacity("Opacity", Range( -1 , 1)) = 0.3
		_FoamVertexOffsetAmount("FoamVertexOffsetAmount", Range( 0 , 10)) = 1
		_VoronoiScale("VoronoiScale", Range( 0 , 10)) = 5
		_NoiseTexture("NoiseTexture", 2D) = "white" {}
		[HDR]_WaterColor("WaterColor", Color) = (0,0,0,0)
		_Foam("Foam", Range( 0 , 1)) = 0
		_Float1("Float 1", Range( -2 , 2)) = -2
		_Opacity2("Opacity2", Range( 0 , 1)) = 0
		_Noise("Noise", Range( 0 , 1)) = 0
		_VectorStrength("VectorStrength", Vector) = (10,4.71,1,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
		};

		uniform float _VoronoiScale;
		uniform float2 _voronoispeed;
		uniform float2 _RippSpeed;
		uniform sampler2D _NoiseTexture;
		uniform float _Noise;
		uniform float _RipplesAmount;
		uniform float3 _VectorStrength;
		uniform float _Foam;
		uniform float _FoamVertexOffsetAmount;
		uniform float4 _WaterColor;
		uniform float _Opacity2;
		uniform float _Opacity;
		uniform float _Float1;
		uniform sampler2D _GrabTexture;
		uniform float _Refraction;
		uniform float _Cutoff = 0.5;


		float2 voronoihash15( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi15( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash15( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float time15 = ( _voronoispeed * _Time.y ).x;
			float2 voronoiSmoothId15 = 0;
			float2 temp_output_16_0 = ( v.texcoord.xy + ( _RippSpeed * _Time.y ) );
			float2 coords15 = temp_output_16_0 * _VoronoiScale;
			float2 id15 = 0;
			float2 uv15 = 0;
			float voroi15 = voronoi15( coords15, time15, id15, uv15, 0, voronoiSmoothId15 );
			float4 temp_cast_1 = (_RipplesAmount).xxxx;
			float4 temp_output_42_0 = ( (float4( 0.1,0,0,0 ) + (pow( ( voroi15 + ( tex2Dlod( _NoiseTexture, float4( temp_output_16_0, 0, 0.0) ) * _Noise ) ) , temp_cast_1 ) - float4( 0,0,0,0 )) * (float4( 2,1,1,1 ) - float4( 0.1,0,0,0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) + (0.0 + (( pow( ( 1.0 - v.texcoord.xy.y ) , _VectorStrength.x ) * _Foam ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) );
			float temp_output_88_0 = (temp_output_42_0).r;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( temp_output_88_0 * ase_vertexNormal * _FoamVertexOffsetAmount );
			v.vertex.w = 1;
		}

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) );
			float2 cameraRefraction = float2( refractionOffset.x, refractionOffset.y );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			color.rgb = color.rgb + Refraction( i, o, _Refraction, 0.1 ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float time15 = ( _voronoispeed * _Time.y ).x;
			float2 voronoiSmoothId15 = 0;
			float2 temp_output_16_0 = ( i.uv_texcoord + ( _RippSpeed * _Time.y ) );
			float2 coords15 = temp_output_16_0 * _VoronoiScale;
			float2 id15 = 0;
			float2 uv15 = 0;
			float voroi15 = voronoi15( coords15, time15, id15, uv15, 0, voronoiSmoothId15 );
			float4 temp_cast_1 = (_RipplesAmount).xxxx;
			float4 temp_output_42_0 = ( (float4( 0.1,0,0,0 ) + (pow( ( voroi15 + ( tex2D( _NoiseTexture, temp_output_16_0 ) * _Noise ) ) , temp_cast_1 ) - float4( 0,0,0,0 )) * (float4( 2,1,1,1 ) - float4( 0.1,0,0,0 )) / (float4( 1,1,1,1 ) - float4( 0,0,0,0 ))) + (0.0 + (( pow( ( 1.0 - i.uv_texcoord.y ) , _VectorStrength.x ) * _Foam ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) );
			float temp_output_88_0 = (temp_output_42_0).r;
			float4 lerpResult87 = lerp( _WaterColor , float4( 0,0,0,0 ) , temp_output_88_0);
			o.Albedo = lerpResult87.rgb;
			float3 temp_cast_4 = (( ( 1.0 - _Opacity2 ) * temp_output_88_0 )).xxx;
			o.Emission = temp_cast_4;
			float3 desaturateInitialColor81 = lerpResult87.rgb;
			float desaturateDot81 = dot( desaturateInitialColor81, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar81 = lerp( desaturateInitialColor81, desaturateDot81.xxx, 0.0 );
			float lerpResult84 = lerp( _Opacity , 1.0 , (saturate( desaturateVar81 )).x);
			o.Alpha = lerpResult84;
			clip( ( 1.0 - ( ( temp_output_42_0 * ( 1.0 - i.uv_texcoord.y ) ) + _Float1 ) ).r - _Cutoff );
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float4 tSpace0 : TEXCOORD4;
				float4 tSpace1 : TEXCOORD5;
				float4 tSpace2 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
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
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18921
561;73;990;642;658.2628;-100.2847;2.0681;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;12;-1341.331,406.6423;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;14;-1307.374,610.2748;Inherit;False;Property;_RippSpeed;RippSpeed;3;0;Create;True;0;0;0;False;0;False;0,1.52;0,0.9;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1116.436,613.908;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1197.054,493.3878;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-916.3687,405.2329;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;18;-943.2538,-92.82565;Inherit;False;Property;_voronoispeed;voronoispeed;4;0;Create;True;0;0;0;True;0;False;2,2;2,7;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.BreakToComponentsNode;32;-567.3106,475.8023;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;76;-399.0993,354.4028;Inherit;False;Property;_Noise;Noise;15;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-680.7494,141.5592;Inherit;False;Property;_VoronoiScale;VoronoiScale;9;0;Create;True;0;0;0;False;0;False;5;6.66;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;74;-689.6243,244.2092;Inherit;True;Property;_NoiseTexture;NoiseTexture;10;0;Create;True;0;0;0;False;0;False;-1;f13fe5fc5af2ce044ab14c852d11ba2f;f13fe5fc5af2ce044ab14c852d11ba2f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-752.286,-89.02268;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;44;-482.4474,609.0233;Inherit;False;Property;_VectorStrength;VectorStrength;16;0;Create;True;0;0;0;False;0;False;10,4.71,1;2,8,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-322.9216,263.8145;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VoronoiNode;15;-580.7933,-116.7638;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;5;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.OneMinusNode;33;-380.2493,494.196;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;54.18806,683.8252;Inherit;False;Property;_Foam;Foam;12;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-60.61266,357.7558;Inherit;False;Property;_RipplesAmount;RipplesAmount;5;0;Create;True;0;0;0;False;0;False;0;2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-169.2018,145.3394;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;34;-193.2488,494.196;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT3;1,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;123.1937,475.6777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;19;-15.13461,145.7418;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;4.5;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;41;271.3756,475.9104;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;30;255.7365,144.8715;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;3;COLOR;0.1,0,0,0;False;4;COLOR;2,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;445.5737,144.3046;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;88;706.977,70.50568;Inherit;False;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;105;627.2432,-183.8647;Inherit;False;Property;_WaterColor;WaterColor;11;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.259434,0.9663379,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;192;321.889,365.0846;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;87;943.6218,-31.39619;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;191;464.9188,367.7021;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;81;1185,64;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;104;1046.39,1059.842;Inherit;False;707.656;318.411;FoamVertexOffsetAmount;3;93;95;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;82;1408,176;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;195;650.7767,172.2619;Inherit;False;Property;_Opacity2;Opacity2;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;716.8613,293.2927;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;184;719.9452,508.4282;Inherit;False;Property;_Float1;Float 1;13;0;Create;True;0;0;0;False;0;False;-2;0.21;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;1096.39,1262.25;Inherit;False;Property;_FoamVertexOffsetAmount;FoamVertexOffsetAmount;8;0;Create;True;0;0;0;False;0;False;1;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;203;954.3226,168.9209;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;93;1194.746,1113.241;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;1491.616,402.168;Inherit;False;Property;_Opacity;Opacity;7;0;Create;True;0;0;0;False;0;False;0.3;-0.7;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;83;1548,254;Inherit;False;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;1603.616,482.1681;Inherit;False;Constant;_Float0;Float 0;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;91;1617.505,31.73413;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;1010.456,432.416;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;202;1146.144,172.7682;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;92;1695.905,135.7341;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;1454.046,1134.84;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;67;1918,325;Inherit;False;Property;_Refraction;Refraction;6;0;Create;True;0;0;0;False;0;False;1.03;1.03;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;193;1329.506,483.5342;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;84;1791.028,402.168;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2235.352,182.5509;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;waterfall;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;14;0
WireConnection;13;1;12;0
WireConnection;16;0;11;0
WireConnection;16;1;13;0
WireConnection;32;0;11;0
WireConnection;74;1;16;0
WireConnection;17;0;18;0
WireConnection;17;1;12;0
WireConnection;78;0;74;0
WireConnection;78;1;76;0
WireConnection;15;0;16;0
WireConnection;15;1;17;0
WireConnection;15;2;65;0
WireConnection;33;0;32;1
WireConnection;80;0;15;0
WireConnection;80;1;78;0
WireConnection;34;0;33;0
WireConnection;34;1;44;0
WireConnection;35;0;34;0
WireConnection;35;1;123;0
WireConnection;19;0;80;0
WireConnection;19;1;66;0
WireConnection;41;0;35;0
WireConnection;30;0;19;0
WireConnection;42;0;30;0
WireConnection;42;1;41;0
WireConnection;88;0;42;0
WireConnection;192;0;11;0
WireConnection;87;0;105;0
WireConnection;87;2;88;0
WireConnection;191;0;192;1
WireConnection;81;0;87;0
WireConnection;82;0;81;0
WireConnection;190;0;42;0
WireConnection;190;1;191;0
WireConnection;203;0;195;0
WireConnection;83;0;82;0
WireConnection;91;0;87;0
WireConnection;188;0;190;0
WireConnection;188;1;184;0
WireConnection;202;0;203;0
WireConnection;202;1;88;0
WireConnection;92;0;91;0
WireConnection;94;0;88;0
WireConnection;94;1;93;0
WireConnection;94;2;95;0
WireConnection;193;0;188;0
WireConnection;84;0;68;0
WireConnection;84;1;85;0
WireConnection;84;2;83;0
WireConnection;0;0;92;0
WireConnection;0;2;202;0
WireConnection;0;8;67;0
WireConnection;0;9;84;0
WireConnection;0;10;193;0
WireConnection;0;11;94;0
ASEEND*/
//CHKSM=675A7CD79FD1E727FED24AABBFC998C5659C5B1B