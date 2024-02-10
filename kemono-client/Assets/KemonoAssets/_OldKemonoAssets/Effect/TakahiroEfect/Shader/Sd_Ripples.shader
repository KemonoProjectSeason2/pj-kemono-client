// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ripples"
{
	Properties
	{
		[HDR]_Color("Color ", Color) = (1,1,1,1)
		_MainTexture("MainTexture", 2D) = "white" {}
		_ScrollSpeed("ScrollSpeed", Vector) = (0,0.2,0,0)
		_Mask("Mask", 2D) = "white" {}
		_VoronoiSpeed("VoronoiSpeed", Vector) = (0,-2,0,0)
		_VoronoiScale("VoronoiScale", Range( 0 , 10)) = 5.1
		_DistotionAmount("DistotionAmount", Range( 0 , 10)) = 0
		_DissolveAmount("DissolveAmount", Range( 0 , 5)) = 0
		_FoamVertexOffsetAmount("FoamVertexOffsetAmount", Range( 0 , 10)) = 4.455853
		_DissolvePower("DissolvePower", Range( 0 , 2)) = 0.4597143
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform float2 _VoronoiSpeed;
		uniform float _VoronoiScale;
		uniform float _FoamVertexOffsetAmount;
		uniform float4 _Color;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _DissolvePower;
		uniform sampler2D _MainTexture;
		uniform float2 _ScrollSpeed;
		uniform float _DistotionAmount;
		uniform float _DissolveAmount;


		inline float2 UnityVoronoiRandomVector( float2 UV, float offset )
		{
			float2x2 m = float2x2( 15.27, 47.63, 99.41, 89.98 );
			UV = frac( sin(mul(UV, m) ) * 46839.32 );
			return float2( sin(UV.y* +offset ) * 0.5 + 0.5, cos( UV.x* offset ) * 0.5 + 0.5 );
		}
		
		//x - Out y - Cells
		float3 UnityVoronoi( float2 UV, float AngleOffset, float CellDensity, inout float2 mr )
		{
			float2 g = floor( UV * CellDensity );
			float2 f = frac( UV * CellDensity );
			float t = 8.0;
			float3 res = float3( 8.0, 0.0, 0.0 );
		
			for( int y = -1; y <= 1; y++ )
			{
				for( int x = -1; x <= 1; x++ )
				{
					float2 lattice = float2( x, y );
					float2 offset = UnityVoronoiRandomVector( lattice + g, AngleOffset );
					float d = distance( lattice + offset, f );
		
					if( d < res.x )
					{
						mr = f - lattice - offset;
						res = float3( d, offset.x, offset.y );
					}
				}
			}
			return res;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 uv33 = 0;
			float3 unityVoronoy33 = UnityVoronoi(( v.texcoord.xy + ( _Time.y * _VoronoiSpeed ) ),5.0,_VoronoiScale,uv33);
			float3 temp_cast_0 = (unityVoronoy33.x).xxx;
			float3 desaturateInitialColor58 = temp_cast_0;
			float desaturateDot58 = dot( desaturateInitialColor58, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar58 = lerp( desaturateInitialColor58, desaturateDot58.xxx, 0.0 );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( (desaturateVar58).x * ase_vertexNormal * _FoamVertexOffsetAmount );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float2 temp_output_14_0 = ( i.uv_texcoord + ( _ScrollSpeed * _Time.y ) );
			float2 uv33 = 0;
			float3 unityVoronoy33 = UnityVoronoi(( i.uv_texcoord + ( _Time.y * _VoronoiSpeed ) ),5.0,_VoronoiScale,uv33);
			float2 lerpResult29 = lerp( temp_output_14_0 , ( temp_output_14_0 + unityVoronoy33.x ) , _DistotionAmount);
			float4 tex2DNode2 = tex2D( _MainTexture, lerpResult29 );
			float4 lerpResult39 = lerp( tex2DNode2 , ( tex2DNode2 * unityVoronoy33.x ) , _DissolveAmount);
			float4 temp_output_17_0 = ( i.vertexColor * ( _Color * ( tex2D( _Mask, uv_Mask ) * pow( ( _DissolvePower * lerpResult39 ) , 2.0 ) ) ) );
			o.Albedo = temp_output_17_0.rgb;
			o.Alpha = temp_output_17_0.a;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
				half4 color : COLOR0;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				surfIN.vertexColor = IN.color;
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
0;441;1407;558;2101.459;287.3675;2.971853;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;13;-1856,224;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;32;-1824,416;Inherit;False;Property;_VoronoiSpeed;VoronoiSpeed;4;0;Create;True;0;0;0;False;0;False;0,-2;2,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;12;-1504,256;Inherit;False;Property;_ScrollSpeed;ScrollSpeed;2;0;Create;True;0;0;0;False;0;False;0,0.2;0,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-1504,128;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1632,416;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1216,192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1408,512;Inherit;False;Property;_VoronoiScale;VoronoiScale;5;0;Create;True;0;0;0;False;0;False;5.1;6.1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-1280,384;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VoronoiNode;33;-1088,384;Inherit;True;0;0;1;0;1;False;1;True;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;5;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1024,128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-864,192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1024,288;Inherit;False;Property;_DistotionAmount;DistotionAmount;6;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;29;-704,128;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;2;-512,128;Inherit;True;Property;_MainTexture;MainTexture;1;0;Create;True;0;0;0;False;0;False;-1;3ebbd2469f5da634fa3b2a54e9463c6c;3ebbd2469f5da634fa3b2a54e9463c6c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-128,128;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-224,256;Inherit;False;Property;_DissolveAmount;DissolveAmount;7;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-64,32;Inherit;False;Property;_DissolvePower;DissolvePower;9;0;Create;True;0;0;0;False;0;False;0.4597143;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;39;64,128;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;257.2553,128;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;43;416,128;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;2;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;27;320,-96;Inherit;True;Property;_Mask;Mask;3;0;Create;True;0;0;0;False;0;False;-1;7843e83f426827540aef5f9b80afd1f6;7843e83f426827540aef5f9b80afd1f6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;640,-64;Inherit;False;Property;_Color;Color ;0;1;[HDR];Create;True;0;0;0;True;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;672,128;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;18;864,-64;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;58;1226.998,402.0375;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;864,128;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;1056,128;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;52;1525.085,462.5378;Inherit;True;True;False;False;False;1;0;FLOAT3;1,1,1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;57;1526.756,654.4072;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;51;1495.769,836.1216;Inherit;False;Property;_FoamVertexOffsetAmount;FoamVertexOffsetAmount;8;0;Create;True;0;0;0;False;0;False;4.455853;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;19;2068.575,365.0791;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;1826.943,646.2535;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2196.574,109.0792;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Ripples;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;0;13;0
WireConnection;31;1;32;0
WireConnection;11;0;12;0
WireConnection;11;1;13;0
WireConnection;34;0;10;0
WireConnection;34;1;31;0
WireConnection;33;0;34;0
WireConnection;33;2;37;0
WireConnection;14;0;10;0
WireConnection;14;1;11;0
WireConnection;38;0;14;0
WireConnection;38;1;33;0
WireConnection;29;0;14;0
WireConnection;29;1;38;0
WireConnection;29;2;40;0
WireConnection;2;1;29;0
WireConnection;41;0;2;0
WireConnection;41;1;33;0
WireConnection;39;0;2;0
WireConnection;39;1;41;0
WireConnection;39;2;44;0
WireConnection;47;0;45;0
WireConnection;47;1;39;0
WireConnection;43;0;47;0
WireConnection;28;0;27;0
WireConnection;28;1;43;0
WireConnection;58;0;33;0
WireConnection;15;0;1;0
WireConnection;15;1;28;0
WireConnection;17;0;18;0
WireConnection;17;1;15;0
WireConnection;52;0;58;0
WireConnection;19;0;17;0
WireConnection;63;0;52;0
WireConnection;63;1;57;0
WireConnection;63;2;51;0
WireConnection;0;0;17;0
WireConnection;0;9;19;3
WireConnection;0;11;63;0
ASEEND*/
//CHKSM=833EF03391666980C0E476B9323C1AB6645DDC5F