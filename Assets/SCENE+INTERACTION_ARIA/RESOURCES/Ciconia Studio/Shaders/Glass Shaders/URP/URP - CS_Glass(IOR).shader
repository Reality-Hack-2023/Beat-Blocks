Shader "Ciconia Studio/CS_Glass/URP/Glass(IOR)"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Space(15)][Header(Global Properties )][Space(10)]_TilingX("Tiling X", Float) = 0
		_TilingY("Tiling Y", Float) = 0
		[Space(10)]_OffsetX("Offset X", Float) = 0
		_OffsetY("Offset Y", Float) = 0

		[Space(15)]
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 2 //"Back"
		[Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 1.0 //"On"

		[Space(10)][Header(Main Properties)][Space(15)]_Color("Color", Color) = (0,0,0,0)
		[Space(10)]_MainTex("Albedo -->(Mask A)", 2D) = "white" {}
		_Saturation("Saturation", Float) = 0
		_Brightness("Brightness", Range( 1 , 8)) = 1
		[Space(35)]_MetallicGlossMap("Metallic(RoughA)", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 2)) = 0
		_Glossiness("Smoothness", Range( 0 , 1)) = 1
		[Space(35)]_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Scale", Range( 0 , 20)) = 0.1
		[Space(10)]_IndexofRefraction("Index of Refraction", Float) = 1.3
		[Space(35)]_OcclusionMap("Ambient Occlusion Map", 2D) = "white" {}
		_AoIntensity("Ao Intensity", Range( 0 , 2)) = 0
		[Space(45)][Header(Reflection Properties) ][Space(15)]_ColorCubemap("Color ", Color) = (1,1,1,1)
		[HDR]_CubeMap("Cube Map", CUBE) = "black" {}
		_ReflectionIntensity("Reflection Intensity", Float) = 1
		_BlurReflection("Blur", Range( 0 , 8)) = 0
		[Space(15)]_ColorFresnel("Color Fresnel", Color) = (1,1,1,0)
		[ToggleOff(_USECUBEMAP_OFF)] _UseCubemap("Use Cubemap", Float) = 1
		_FresnelStrength("Fresnel Strength", Float) = 0
		_PowerFresnel("Power", Float) = 1
		[Space(45)][Header(Transparency Properties)][Space(15)]_Opacity("Opacity", Range( 0 , 1)) = 0.7
		[Space(10)][Toggle]_UseAlbedoA("Use AlbedoA", Float) = 0
		[Toggle]_InvertAlbedoA("Invert", Float) = 0
		[Space(10)][Toggle]_UseSmoothness("Use Smoothness", Float) = 0
		[Space(10)][Toggle]_FalloffOpacity("Falloff Opacity", Float) = 0
		[Toggle]_Invert("Invert", Float) = 0
		[Space(10)]_FalloffOpacityIntensity("Falloff Intensity", Range( 0 , 1)) = 1
		_PowerFalloffOpacity("Power", Float) = 1
		[Space(45)][Header(Decal Properties)][Space(15)]_ColorDecal("Color -->(Transparency A)", Color) = (1,1,1,1)
		[Space(10)]_DetailAlbedoMap("Decal Map -->(Mask A)", 2D) = "black" {}
		_SaturationDecal("Saturation", Float) = 0
		[Space(20)]_MetallicDecal("Metallic", Range( 0 , 2)) = 0.2
		_GlossinessDecal("Smoothness", Range( 0 , 1)) = 0.5
		_ReflectionDecal("Reflection", Range( 0 , 1)) = 0
		[Space(35)]_DetailNormalMap("Normal Map", 2D) = "bump" {}
		_BumpScaleDecal("Scale", Range( 0 , 5)) = 0.1
		_BumpScaleDecal1("Normal Blend", Range( 0 , 1)) = 0
		[Space(25)]_Rotation("Rotation", Float) = 0
		[HDR][Space(35)]_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_EmissionIntensity("Intensity", Range( 0 , 2)) = 1

		[HideInInspector]_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		[HideInInspector]_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		[HideInInspector]_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		[HideInInspector]_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		[HideInInspector]_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		[HideInInspector]_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		[HideInInspector]_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		[HideInInspector]_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		[HideInInspector]_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		[HideInInspector]_TessMin( "Tess Min Distance", Float ) = 10
		[HideInInspector]_TessMax( "Tess Max Distance", Float ) = 25
		[HideInInspector]_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		[HideInInspector]_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		ZWrite[_ZWrite]
		Cull[_Cull]
		HLSLINCLUDE
		#pragma target 2.0

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _REFRACTION_ASE 1
			#define REQUIRE_OPAQUE_TEXTURE 1
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_FORWARD

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_WORLD_VIEW_DIR
			#define ASE_NEEDS_FRAG_WORLD_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_TANGENT
			#define ASE_NEEDS_FRAG_WORLD_BITANGENT
			#pragma shader_feature_local _USECUBEMAP_OFF


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _ColorCubemap;
			float4 _MetallicGlossMap_ST;
			float4 _ColorFresnel;
			float4 _ColorDecal;
			float4 _DetailAlbedoMap_ST;
			float4 _DetailNormalMap_ST;
			float4 _BumpMap_ST;
			float4 _OcclusionMap_ST;
			float _Metallic;
			float _MetallicDecal;
			float _Glossiness;
			float _GlossinessDecal;
			float _AoIntensity;
			float _UseSmoothness;
			float _UseAlbedoA;
			float _FalloffOpacity;
			float _Opacity;
			float _Invert;
			float _FalloffOpacityIntensity;
			float _PowerFalloffOpacity;
			float _EmissionIntensity;
			float _Brightness;
			float _BlurReflection;
			float _ReflectionIntensity;
			float _InvertAlbedoA;
			float _PowerFresnel;
			float _FresnelStrength;
			float _BumpScaleDecal1;
			float _BumpScaleDecal;
			float _BumpScale;
			float _SaturationDecal;
			float _Rotation;
			float _Saturation;
			float _OffsetY;
			float _OffsetX;
			float _TilingY;
			float _TilingX;
			float _ReflectionDecal;
			float _IndexofRefraction;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DetailAlbedoMap;
			sampler2D _BumpMap;
			sampler2D _DetailNormalMap;
			samplerCUBE _CubeMap;
			sampler2D _MetallicGlossMap;
			sampler2D _OcclusionMap;


			float4 CalculateContrast( float contrastValue, float4 colorTarget )
			{
				float t = 0.5 * ( 1.0 - contrastValue );
				return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
			}

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord7.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord1 = v.texcoord1;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 WorldNormal = normalize( IN.tSpace0.xyz );
				float3 WorldTangent = IN.tSpace1.xyz;
				float3 WorldBiTangent = IN.tSpace2.xyz;
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				#if SHADER_HINT_NICE_QUALITY
					WorldViewDirection = SafeNormalize( WorldViewDirection );
				#endif

				float2 uv0_MainTex = IN.ase_texcoord7.xyz * _MainTex_ST.xy + _MainTex_ST.zw;
				float temp_output_2_0_g6 = uv0_MainTex.x;
				float GlobalTilingX281 = _TilingX;
				float temp_output_21_0_g6 = uv0_MainTex.y;
				float GlobalTilingY282 = _TilingY;
				float2 appendResult14_g6 = (float2(( temp_output_2_0_g6 * GlobalTilingX281 ) , ( temp_output_21_0_g6 * GlobalTilingY282 )));
				float GlobalOffsetX493 = _OffsetX;
				float GlobalOffsetY496 = _OffsetY;
				float2 appendResult13_g6 = (float2(( temp_output_2_0_g6 + GlobalOffsetX493 ) , ( temp_output_21_0_g6 + GlobalOffsetY496 )));
				float4 tex2DNode76 = tex2D( _MainTex, ( appendResult14_g6 + appendResult13_g6 ) );
				float4 temp_output_297_0 = ( _Color * tex2DNode76 );
				float clampResult239 = clamp( _Saturation , -1.0 , 100.0 );
				float3 desaturateInitialColor211 = temp_output_297_0.rgb;
				float desaturateDot211 = dot( desaturateInitialColor211, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar211 = lerp( desaturateInitialColor211, desaturateDot211.xxx, -clampResult239 );
				float4 temp_output_303_0 = CalculateContrast(_Brightness,float4( desaturateVar211 , 0.0 ));
				float2 uv0_DetailAlbedoMap = IN.ase_texcoord7.xyz.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float cos400 = cos( radians( _Rotation ) );
				float sin400 = sin( radians( _Rotation ) );
				float2 rotator400 = mul( uv0_DetailAlbedoMap - float2( 0.5,0.5 ) , float2x2( cos400 , -sin400 , sin400 , cos400 )) + float2( 0.5,0.5 );
				float4 tex2DNode181 = tex2D( _DetailAlbedoMap, rotator400 );
				float clampResult235 = clamp( _SaturationDecal , -1.0 , 100.0 );
				float3 desaturateInitialColor203 = tex2DNode181.rgb;
				float desaturateDot203 = dot( desaturateInitialColor203, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar203 = lerp( desaturateInitialColor203, desaturateDot203.xxx, -clampResult235 );
				float4 Decal248 = ( _ColorDecal * float4( desaturateVar203 , 0.0 ) );
				float DecalOpacity251 = _ColorDecal.a;
				float DecalMask182 = ( tex2DNode181.a * DecalOpacity251 );
				float4 lerpResult183 = lerp( temp_output_303_0 , Decal248 , DecalMask182);
				float4 AlbedoAmbient117 = lerpResult183;
				
				float2 uv0_BumpMap = IN.ase_texcoord7.xyz.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float temp_output_2_0_g5 = uv0_BumpMap.x;
				float temp_output_21_0_g5 = uv0_BumpMap.y;
				float2 appendResult14_g5 = (float2(( temp_output_2_0_g5 * GlobalTilingX281 ) , ( temp_output_21_0_g5 * GlobalTilingY282 )));
				float2 appendResult13_g5 = (float2(( temp_output_2_0_g5 + GlobalOffsetX493 ) , ( temp_output_21_0_g5 + GlobalOffsetY496 )));
				float3 tex2DNode2 = UnpackNormalScale( tex2D( _BumpMap, ( appendResult14_g5 + appendResult13_g5 ) ), _BumpScale );
				float2 uv0_DetailNormalMap = IN.ase_texcoord7.xyz.xy * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
				float Rotator_Detailsmaps411 = _Rotation;
				float cos409 = cos( radians( Rotator_Detailsmaps411 ) );
				float sin409 = sin( radians( Rotator_Detailsmaps411 ) );
				float2 rotator409 = mul( uv0_DetailNormalMap - float2( 0.5,0.5 ) , float2x2( cos409 , -sin409 , sin409 , cos409 )) + float2( 0.5,0.5 );
				float3 tex2DNode194 = UnpackNormalScale( tex2D( _DetailNormalMap, rotator409 ), _BumpScaleDecal );
				float3 lerpResult308 = lerp( tex2DNode194 , BlendNormal( tex2DNode2 , tex2DNode194 ) , _BumpScaleDecal1);
				float3 lerpResult192 = lerp( tex2DNode2 , lerpResult308 , DecalMask182);
				float3 Normal101 = lerpResult192;
				
				float fresnelNdotV163 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode163 = ( -0.05 + 1.0 * pow( 1.0 - fresnelNdotV163, _PowerFresnel ) );
				float4 clampResult482 = clamp( ( _ColorFresnel * fresnelNode163 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				float4 ifLocalVar474 = 0;
				if( 0.0 > _FresnelStrength )
				ifLocalVar474 = float4( ( float3(1,1,1) * fresnelNode163 ) , 0.0 );
				else if( 0.0 < _FresnelStrength )
				ifLocalVar474 = clampResult482;
				float clampResult488 = clamp( _FresnelStrength , -1.0 , 75.0 );
				float3 NormalmapXYZ170 = tex2DNode2;
				float3 tanToWorld0 = float3( WorldTangent.x, WorldBiTangent.x, WorldNormal.x );
				float3 tanToWorld1 = float3( WorldTangent.y, WorldBiTangent.y, WorldNormal.y );
				float3 tanToWorld2 = float3( WorldTangent.z, WorldBiTangent.z, WorldNormal.z );
				float3 worldRefl3 = reflect( -WorldViewDirection, float3( dot( tanToWorld0, NormalmapXYZ170 ), dot( tanToWorld1, NormalmapXYZ170 ), dot( tanToWorld2, NormalmapXYZ170 ) ) );
				float4 texCUBENode6 = texCUBElod( _CubeMap, float4( worldRefl3, _BlurReflection) );
				float4 temp_cast_6 = (1.0).xxxx;
				#ifdef _USECUBEMAP_OFF
				float4 staticSwitch457 = temp_cast_6;
				#else
				float4 staticSwitch457 = texCUBENode6;
				#endif
				float4 temp_output_169_0 = ( ( ( ifLocalVar474 * clampResult488 ) * staticSwitch457 ) + ( texCUBENode6 * ( texCUBENode6.a * _ReflectionIntensity ) * _ColorCubemap ) );
				float4 lerpResult292 = lerp( temp_output_169_0 , ( temp_output_169_0 * _ReflectionDecal ) , DecalMask182);
				float4 Cubmap179 = lerpResult292;
				float4 AlbedoDecal_RGB232 = tex2DNode181;
				float4 Emission220 = ( ( _EmissionColor * AlbedoDecal_RGB232 * _EmissionIntensity ) * DecalMask182 );
				
				float2 uv0_MetallicGlossMap = IN.ase_texcoord7.xyz.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float temp_output_2_0_g7 = uv0_MetallicGlossMap.x;
				float temp_output_21_0_g7 = uv0_MetallicGlossMap.y;
				float2 appendResult14_g7 = (float2(( temp_output_2_0_g7 * GlobalTilingX281 ) , ( temp_output_21_0_g7 * GlobalTilingY282 )));
				float2 appendResult13_g7 = (float2(( temp_output_2_0_g7 + GlobalOffsetX493 ) , ( temp_output_21_0_g7 + GlobalOffsetY496 )));
				float4 tex2DNode123 = tex2D( _MetallicGlossMap, ( appendResult14_g7 + appendResult13_g7 ) );
				float lerpResult264 = lerp( ( _Metallic * tex2DNode123.r ) , _MetallicDecal , DecalMask182);
				float Metallic110 = lerpResult264;
				
				float lerpResult185 = lerp( ( tex2DNode123.a * _Glossiness ) , ( tex2DNode123.a * _GlossinessDecal ) , DecalMask182);
				float Roughness111 = lerpResult185;
				
				float2 uv0_OcclusionMap = IN.ase_texcoord7.xyz.xy * _OcclusionMap_ST.xy + _OcclusionMap_ST.zw;
				float temp_output_2_0_g8 = uv0_OcclusionMap.x;
				float temp_output_21_0_g8 = uv0_OcclusionMap.y;
				float2 appendResult14_g8 = (float2(( temp_output_2_0_g8 * GlobalTilingX281 ) , ( temp_output_21_0_g8 * GlobalTilingY282 )));
				float2 appendResult13_g8 = (float2(( temp_output_2_0_g8 + GlobalOffsetX493 ) , ( temp_output_21_0_g8 + GlobalOffsetY496 )));
				float blendOpSrc136 = tex2D( _OcclusionMap, ( appendResult14_g8 + appendResult13_g8 ) ).r;
				float blendOpDest136 = ( 1.0 - _AoIntensity );
				float Occlusion140 = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc136 ) * ( 1.0 - blendOpDest136 ) ) ));
				
				float lerpResult68 = lerp( -3.0 , 0.0 , _FalloffOpacityIntensity);
				float fresnelNdotV25 = dot( WorldNormal, WorldViewDirection );
				float fresnelNode25 = ( lerpResult68 + _PowerFalloffOpacity * pow( 1.0 - fresnelNdotV25, (( 1.0 + -_Opacity ) + (1.0 - 0.0) * (_Opacity - ( 1.0 + -_Opacity )) / (1.0 - 0.0)) ) );
				float clampResult45 = clamp( (( _Invert )?( ( 1.0 - fresnelNode25 ) ):( fresnelNode25 )) , 0.0 , 1.0 );
				float AlbedoA250 = tex2DNode76.a;
				float RougnessA370 = tex2DNode123.a;
				float lerpResult189 = lerp( (( _UseSmoothness )?( ( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) * RougnessA370 ) ):( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) )) , 1.0 , DecalMask182);
				float Opacity87 = lerpResult189;
				
				float IOR103 = _IndexofRefraction;
				
				float3 Albedo = AlbedoAmbient117.rgb;
				float3 Normal = Normal101;
				float3 Emission = ( Cubmap179 + Emission220 ).rgb;
				float3 Specular = 0.5;
				float Metallic = Metallic110;
				float Smoothness = Roughness111;
				float Occlusion = Occlusion140;
				float Alpha = Opacity87;
				float AlphaClipThreshold = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = IOR103;
				float3 Transmission = 1;
				float3 Translucency = 1;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					inputData.normalWS = normalize(TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal )));
				#else
					#if !SHADER_HINT_NICE_QUALITY
						inputData.normalWS = WorldNormal;
					#else
						inputData.normalWS = normalize( WorldNormal );
					#endif
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif
				half4 color = UniversalFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif

				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;

					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;

					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif

				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, WorldNormal ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif

				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				return color;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _REFRACTION_ASE 1
			#define REQUIRE_OPAQUE_TEXTURE 1
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _ColorCubemap;
			float4 _MetallicGlossMap_ST;
			float4 _ColorFresnel;
			float4 _ColorDecal;
			float4 _DetailAlbedoMap_ST;
			float4 _DetailNormalMap_ST;
			float4 _BumpMap_ST;
			float4 _OcclusionMap_ST;
			float _Metallic;
			float _MetallicDecal;
			float _Glossiness;
			float _GlossinessDecal;
			float _AoIntensity;
			float _UseSmoothness;
			float _UseAlbedoA;
			float _FalloffOpacity;
			float _Opacity;
			float _Invert;
			float _FalloffOpacityIntensity;
			float _PowerFalloffOpacity;
			float _EmissionIntensity;
			float _Brightness;
			float _BlurReflection;
			float _ReflectionIntensity;
			float _InvertAlbedoA;
			float _PowerFresnel;
			float _FresnelStrength;
			float _BumpScaleDecal1;
			float _BumpScaleDecal;
			float _BumpScale;
			float _SaturationDecal;
			float _Rotation;
			float _Saturation;
			float _OffsetY;
			float _OffsetX;
			float _TilingY;
			float _TilingX;
			float _ReflectionDecal;
			float _IndexofRefraction;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _MetallicGlossMap;
			sampler2D _DetailAlbedoMap;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord2.xyz;
				float lerpResult68 = lerp( -3.0 , 0.0 , _FalloffOpacityIntensity);
				float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode25 = ( lerpResult68 + _PowerFalloffOpacity * pow( 1.0 - fresnelNdotV25, (( 1.0 + -_Opacity ) + (1.0 - 0.0) * (_Opacity - ( 1.0 + -_Opacity )) / (1.0 - 0.0)) ) );
				float clampResult45 = clamp( (( _Invert )?( ( 1.0 - fresnelNode25 ) ):( fresnelNode25 )) , 0.0 , 1.0 );
				float2 uv0_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float temp_output_2_0_g6 = uv0_MainTex.x;
				float GlobalTilingX281 = _TilingX;
				float temp_output_21_0_g6 = uv0_MainTex.y;
				float GlobalTilingY282 = _TilingY;
				float2 appendResult14_g6 = (float2(( temp_output_2_0_g6 * GlobalTilingX281 ) , ( temp_output_21_0_g6 * GlobalTilingY282 )));
				float GlobalOffsetX493 = _OffsetX;
				float GlobalOffsetY496 = _OffsetY;
				float2 appendResult13_g6 = (float2(( temp_output_2_0_g6 + GlobalOffsetX493 ) , ( temp_output_21_0_g6 + GlobalOffsetY496 )));
				float4 tex2DNode76 = tex2D( _MainTex, ( appendResult14_g6 + appendResult13_g6 ) );
				float AlbedoA250 = tex2DNode76.a;
				float2 uv0_MetallicGlossMap = IN.ase_texcoord3.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float temp_output_2_0_g7 = uv0_MetallicGlossMap.x;
				float temp_output_21_0_g7 = uv0_MetallicGlossMap.y;
				float2 appendResult14_g7 = (float2(( temp_output_2_0_g7 * GlobalTilingX281 ) , ( temp_output_21_0_g7 * GlobalTilingY282 )));
				float2 appendResult13_g7 = (float2(( temp_output_2_0_g7 + GlobalOffsetX493 ) , ( temp_output_21_0_g7 + GlobalOffsetY496 )));
				float4 tex2DNode123 = tex2D( _MetallicGlossMap, ( appendResult14_g7 + appendResult13_g7 ) );
				float RougnessA370 = tex2DNode123.a;
				float2 uv0_DetailAlbedoMap = IN.ase_texcoord3.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float cos400 = cos( radians( _Rotation ) );
				float sin400 = sin( radians( _Rotation ) );
				float2 rotator400 = mul( uv0_DetailAlbedoMap - float2( 0.5,0.5 ) , float2x2( cos400 , -sin400 , sin400 , cos400 )) + float2( 0.5,0.5 );
				float4 tex2DNode181 = tex2D( _DetailAlbedoMap, rotator400 );
				float DecalOpacity251 = _ColorDecal.a;
				float DecalMask182 = ( tex2DNode181.a * DecalOpacity251 );
				float lerpResult189 = lerp( (( _UseSmoothness )?( ( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) * RougnessA370 ) ):( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) )) , 1.0 , DecalMask182);
				float Opacity87 = lerpResult189;
				
				float Alpha = Opacity87;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _REFRACTION_ASE 1
			#define REQUIRE_OPAQUE_TEXTURE 1
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _ColorCubemap;
			float4 _MetallicGlossMap_ST;
			float4 _ColorFresnel;
			float4 _ColorDecal;
			float4 _DetailAlbedoMap_ST;
			float4 _DetailNormalMap_ST;
			float4 _BumpMap_ST;
			float4 _OcclusionMap_ST;
			float _Metallic;
			float _MetallicDecal;
			float _Glossiness;
			float _GlossinessDecal;
			float _AoIntensity;
			float _UseSmoothness;
			float _UseAlbedoA;
			float _FalloffOpacity;
			float _Opacity;
			float _Invert;
			float _FalloffOpacityIntensity;
			float _PowerFalloffOpacity;
			float _EmissionIntensity;
			float _Brightness;
			float _BlurReflection;
			float _ReflectionIntensity;
			float _InvertAlbedoA;
			float _PowerFresnel;
			float _FresnelStrength;
			float _BumpScaleDecal1;
			float _BumpScaleDecal;
			float _BumpScale;
			float _SaturationDecal;
			float _Rotation;
			float _Saturation;
			float _OffsetY;
			float _OffsetX;
			float _TilingY;
			float _TilingX;
			float _ReflectionDecal;
			float _IndexofRefraction;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _MetallicGlossMap;
			sampler2D _DetailAlbedoMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord2.xyz;
				float lerpResult68 = lerp( -3.0 , 0.0 , _FalloffOpacityIntensity);
				float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode25 = ( lerpResult68 + _PowerFalloffOpacity * pow( 1.0 - fresnelNdotV25, (( 1.0 + -_Opacity ) + (1.0 - 0.0) * (_Opacity - ( 1.0 + -_Opacity )) / (1.0 - 0.0)) ) );
				float clampResult45 = clamp( (( _Invert )?( ( 1.0 - fresnelNode25 ) ):( fresnelNode25 )) , 0.0 , 1.0 );
				float2 uv0_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float temp_output_2_0_g6 = uv0_MainTex.x;
				float GlobalTilingX281 = _TilingX;
				float temp_output_21_0_g6 = uv0_MainTex.y;
				float GlobalTilingY282 = _TilingY;
				float2 appendResult14_g6 = (float2(( temp_output_2_0_g6 * GlobalTilingX281 ) , ( temp_output_21_0_g6 * GlobalTilingY282 )));
				float GlobalOffsetX493 = _OffsetX;
				float GlobalOffsetY496 = _OffsetY;
				float2 appendResult13_g6 = (float2(( temp_output_2_0_g6 + GlobalOffsetX493 ) , ( temp_output_21_0_g6 + GlobalOffsetY496 )));
				float4 tex2DNode76 = tex2D( _MainTex, ( appendResult14_g6 + appendResult13_g6 ) );
				float AlbedoA250 = tex2DNode76.a;
				float2 uv0_MetallicGlossMap = IN.ase_texcoord3.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float temp_output_2_0_g7 = uv0_MetallicGlossMap.x;
				float temp_output_21_0_g7 = uv0_MetallicGlossMap.y;
				float2 appendResult14_g7 = (float2(( temp_output_2_0_g7 * GlobalTilingX281 ) , ( temp_output_21_0_g7 * GlobalTilingY282 )));
				float2 appendResult13_g7 = (float2(( temp_output_2_0_g7 + GlobalOffsetX493 ) , ( temp_output_21_0_g7 + GlobalOffsetY496 )));
				float4 tex2DNode123 = tex2D( _MetallicGlossMap, ( appendResult14_g7 + appendResult13_g7 ) );
				float RougnessA370 = tex2DNode123.a;
				float2 uv0_DetailAlbedoMap = IN.ase_texcoord3.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float cos400 = cos( radians( _Rotation ) );
				float sin400 = sin( radians( _Rotation ) );
				float2 rotator400 = mul( uv0_DetailAlbedoMap - float2( 0.5,0.5 ) , float2x2( cos400 , -sin400 , sin400 , cos400 )) + float2( 0.5,0.5 );
				float4 tex2DNode181 = tex2D( _DetailAlbedoMap, rotator400 );
				float DecalOpacity251 = _ColorDecal.a;
				float DecalMask182 = ( tex2DNode181.a * DecalOpacity251 );
				float lerpResult189 = lerp( (( _UseSmoothness )?( ( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) * RougnessA370 ) ):( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) )) , 1.0 , DecalMask182);
				float Opacity87 = lerpResult189;
				
				float Alpha = Opacity87;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _REFRACTION_ASE 1
			#define REQUIRE_OPAQUE_TEXTURE 1
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _USECUBEMAP_OFF


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _ColorCubemap;
			float4 _MetallicGlossMap_ST;
			float4 _ColorFresnel;
			float4 _ColorDecal;
			float4 _DetailAlbedoMap_ST;
			float4 _DetailNormalMap_ST;
			float4 _BumpMap_ST;
			float4 _OcclusionMap_ST;
			float _Metallic;
			float _MetallicDecal;
			float _Glossiness;
			float _GlossinessDecal;
			float _AoIntensity;
			float _UseSmoothness;
			float _UseAlbedoA;
			float _FalloffOpacity;
			float _Opacity;
			float _Invert;
			float _FalloffOpacityIntensity;
			float _PowerFalloffOpacity;
			float _EmissionIntensity;
			float _Brightness;
			float _BlurReflection;
			float _ReflectionIntensity;
			float _InvertAlbedoA;
			float _PowerFresnel;
			float _FresnelStrength;
			float _BumpScaleDecal1;
			float _BumpScaleDecal;
			float _BumpScale;
			float _SaturationDecal;
			float _Rotation;
			float _Saturation;
			float _OffsetY;
			float _OffsetX;
			float _TilingY;
			float _TilingX;
			float _ReflectionDecal;
			float _IndexofRefraction;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DetailAlbedoMap;
			samplerCUBE _CubeMap;
			sampler2D _BumpMap;
			sampler2D _MetallicGlossMap;


			float4 CalculateContrast( float contrastValue, float4 colorTarget )
			{
				float t = 0.5 * ( 1.0 - contrastValue );
				return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
			}

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv0_MainTex = IN.ase_texcoord2.xyz * _MainTex_ST.xy + _MainTex_ST.zw;
				float temp_output_2_0_g6 = uv0_MainTex.x;
				float GlobalTilingX281 = _TilingX;
				float temp_output_21_0_g6 = uv0_MainTex.y;
				float GlobalTilingY282 = _TilingY;
				float2 appendResult14_g6 = (float2(( temp_output_2_0_g6 * GlobalTilingX281 ) , ( temp_output_21_0_g6 * GlobalTilingY282 )));
				float GlobalOffsetX493 = _OffsetX;
				float GlobalOffsetY496 = _OffsetY;
				float2 appendResult13_g6 = (float2(( temp_output_2_0_g6 + GlobalOffsetX493 ) , ( temp_output_21_0_g6 + GlobalOffsetY496 )));
				float4 tex2DNode76 = tex2D( _MainTex, ( appendResult14_g6 + appendResult13_g6 ) );
				float4 temp_output_297_0 = ( _Color * tex2DNode76 );
				float clampResult239 = clamp( _Saturation , -1.0 , 100.0 );
				float3 desaturateInitialColor211 = temp_output_297_0.rgb;
				float desaturateDot211 = dot( desaturateInitialColor211, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar211 = lerp( desaturateInitialColor211, desaturateDot211.xxx, -clampResult239 );
				float4 temp_output_303_0 = CalculateContrast(_Brightness,float4( desaturateVar211 , 0.0 ));
				float2 uv0_DetailAlbedoMap = IN.ase_texcoord2.xyz.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float cos400 = cos( radians( _Rotation ) );
				float sin400 = sin( radians( _Rotation ) );
				float2 rotator400 = mul( uv0_DetailAlbedoMap - float2( 0.5,0.5 ) , float2x2( cos400 , -sin400 , sin400 , cos400 )) + float2( 0.5,0.5 );
				float4 tex2DNode181 = tex2D( _DetailAlbedoMap, rotator400 );
				float clampResult235 = clamp( _SaturationDecal , -1.0 , 100.0 );
				float3 desaturateInitialColor203 = tex2DNode181.rgb;
				float desaturateDot203 = dot( desaturateInitialColor203, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar203 = lerp( desaturateInitialColor203, desaturateDot203.xxx, -clampResult235 );
				float4 Decal248 = ( _ColorDecal * float4( desaturateVar203 , 0.0 ) );
				float DecalOpacity251 = _ColorDecal.a;
				float DecalMask182 = ( tex2DNode181.a * DecalOpacity251 );
				float4 lerpResult183 = lerp( temp_output_303_0 , Decal248 , DecalMask182);
				float4 AlbedoAmbient117 = lerpResult183;
				
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV163 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode163 = ( -0.05 + 1.0 * pow( 1.0 - fresnelNdotV163, _PowerFresnel ) );
				float4 clampResult482 = clamp( ( _ColorFresnel * fresnelNode163 ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				float4 ifLocalVar474 = 0;
				if( 0.0 > _FresnelStrength )
				ifLocalVar474 = float4( ( float3(1,1,1) * fresnelNode163 ) , 0.0 );
				else if( 0.0 < _FresnelStrength )
				ifLocalVar474 = clampResult482;
				float clampResult488 = clamp( _FresnelStrength , -1.0 , 75.0 );
				float2 uv0_BumpMap = IN.ase_texcoord2.xyz.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float temp_output_2_0_g5 = uv0_BumpMap.x;
				float temp_output_21_0_g5 = uv0_BumpMap.y;
				float2 appendResult14_g5 = (float2(( temp_output_2_0_g5 * GlobalTilingX281 ) , ( temp_output_21_0_g5 * GlobalTilingY282 )));
				float2 appendResult13_g5 = (float2(( temp_output_2_0_g5 + GlobalOffsetX493 ) , ( temp_output_21_0_g5 + GlobalOffsetY496 )));
				float3 tex2DNode2 = UnpackNormalScale( tex2D( _BumpMap, ( appendResult14_g5 + appendResult13_g5 ) ), _BumpScale );
				float3 NormalmapXYZ170 = tex2DNode2;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 worldRefl3 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, NormalmapXYZ170 ), dot( tanToWorld1, NormalmapXYZ170 ), dot( tanToWorld2, NormalmapXYZ170 ) ) );
				float4 texCUBENode6 = texCUBElod( _CubeMap, float4( worldRefl3, _BlurReflection) );
				float4 temp_cast_6 = (1.0).xxxx;
				#ifdef _USECUBEMAP_OFF
				float4 staticSwitch457 = temp_cast_6;
				#else
				float4 staticSwitch457 = texCUBENode6;
				#endif
				float4 temp_output_169_0 = ( ( ( ifLocalVar474 * clampResult488 ) * staticSwitch457 ) + ( texCUBENode6 * ( texCUBENode6.a * _ReflectionIntensity ) * _ColorCubemap ) );
				float4 lerpResult292 = lerp( temp_output_169_0 , ( temp_output_169_0 * _ReflectionDecal ) , DecalMask182);
				float4 Cubmap179 = lerpResult292;
				float4 AlbedoDecal_RGB232 = tex2DNode181;
				float4 Emission220 = ( ( _EmissionColor * AlbedoDecal_RGB232 * _EmissionIntensity ) * DecalMask182 );
				
				float lerpResult68 = lerp( -3.0 , 0.0 , _FalloffOpacityIntensity);
				float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode25 = ( lerpResult68 + _PowerFalloffOpacity * pow( 1.0 - fresnelNdotV25, (( 1.0 + -_Opacity ) + (1.0 - 0.0) * (_Opacity - ( 1.0 + -_Opacity )) / (1.0 - 0.0)) ) );
				float clampResult45 = clamp( (( _Invert )?( ( 1.0 - fresnelNode25 ) ):( fresnelNode25 )) , 0.0 , 1.0 );
				float AlbedoA250 = tex2DNode76.a;
				float2 uv0_MetallicGlossMap = IN.ase_texcoord2.xyz.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float temp_output_2_0_g7 = uv0_MetallicGlossMap.x;
				float temp_output_21_0_g7 = uv0_MetallicGlossMap.y;
				float2 appendResult14_g7 = (float2(( temp_output_2_0_g7 * GlobalTilingX281 ) , ( temp_output_21_0_g7 * GlobalTilingY282 )));
				float2 appendResult13_g7 = (float2(( temp_output_2_0_g7 + GlobalOffsetX493 ) , ( temp_output_21_0_g7 + GlobalOffsetY496 )));
				float4 tex2DNode123 = tex2D( _MetallicGlossMap, ( appendResult14_g7 + appendResult13_g7 ) );
				float RougnessA370 = tex2DNode123.a;
				float lerpResult189 = lerp( (( _UseSmoothness )?( ( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) * RougnessA370 ) ):( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) )) , 1.0 , DecalMask182);
				float Opacity87 = lerpResult189;
				
				
				float3 Albedo = AlbedoAmbient117.rgb;
				float3 Emission = ( Cubmap179 + Emission220 ).rgb;
				float Alpha = Opacity87;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _REFRACTION_ASE 1
			#define REQUIRE_OPAQUE_TEXTURE 1
			#define ASE_NEEDS_FRAG_SCREEN_POSITION
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 999999

			#pragma enable_d3d11_debug_symbols
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _EmissionColor;
			float4 _Color;
			float4 _MainTex_ST;
			float4 _ColorCubemap;
			float4 _MetallicGlossMap_ST;
			float4 _ColorFresnel;
			float4 _ColorDecal;
			float4 _DetailAlbedoMap_ST;
			float4 _DetailNormalMap_ST;
			float4 _BumpMap_ST;
			float4 _OcclusionMap_ST;
			float _Metallic;
			float _MetallicDecal;
			float _Glossiness;
			float _GlossinessDecal;
			float _AoIntensity;
			float _UseSmoothness;
			float _UseAlbedoA;
			float _FalloffOpacity;
			float _Opacity;
			float _Invert;
			float _FalloffOpacityIntensity;
			float _PowerFalloffOpacity;
			float _EmissionIntensity;
			float _Brightness;
			float _BlurReflection;
			float _ReflectionIntensity;
			float _InvertAlbedoA;
			float _PowerFresnel;
			float _FresnelStrength;
			float _BumpScaleDecal1;
			float _BumpScaleDecal;
			float _BumpScale;
			float _SaturationDecal;
			float _Rotation;
			float _Saturation;
			float _OffsetY;
			float _OffsetX;
			float _TilingY;
			float _TilingX;
			float _ReflectionDecal;
			float _IndexofRefraction;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _DetailAlbedoMap;
			sampler2D _MetallicGlossMap;


			float4 CalculateContrast( float contrastValue, float4 colorTarget )
			{
				float t = 0.5 * ( 1.0 - contrastValue );
				return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
			}

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv0_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float temp_output_2_0_g6 = uv0_MainTex.x;
				float GlobalTilingX281 = _TilingX;
				float temp_output_21_0_g6 = uv0_MainTex.y;
				float GlobalTilingY282 = _TilingY;
				float2 appendResult14_g6 = (float2(( temp_output_2_0_g6 * GlobalTilingX281 ) , ( temp_output_21_0_g6 * GlobalTilingY282 )));
				float GlobalOffsetX493 = _OffsetX;
				float GlobalOffsetY496 = _OffsetY;
				float2 appendResult13_g6 = (float2(( temp_output_2_0_g6 + GlobalOffsetX493 ) , ( temp_output_21_0_g6 + GlobalOffsetY496 )));
				float4 tex2DNode76 = tex2D( _MainTex, ( appendResult14_g6 + appendResult13_g6 ) );
				float4 temp_output_297_0 = ( _Color * tex2DNode76 );
				float clampResult239 = clamp( _Saturation , -1.0 , 100.0 );
				float3 desaturateInitialColor211 = temp_output_297_0.rgb;
				float desaturateDot211 = dot( desaturateInitialColor211, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar211 = lerp( desaturateInitialColor211, desaturateDot211.xxx, -clampResult239 );
				float4 temp_output_303_0 = CalculateContrast(_Brightness,float4( desaturateVar211 , 0.0 ));
				float2 uv0_DetailAlbedoMap = IN.ase_texcoord2.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float cos400 = cos( radians( _Rotation ) );
				float sin400 = sin( radians( _Rotation ) );
				float2 rotator400 = mul( uv0_DetailAlbedoMap - float2( 0.5,0.5 ) , float2x2( cos400 , -sin400 , sin400 , cos400 )) + float2( 0.5,0.5 );
				float4 tex2DNode181 = tex2D( _DetailAlbedoMap, rotator400 );
				float clampResult235 = clamp( _SaturationDecal , -1.0 , 100.0 );
				float3 desaturateInitialColor203 = tex2DNode181.rgb;
				float desaturateDot203 = dot( desaturateInitialColor203, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar203 = lerp( desaturateInitialColor203, desaturateDot203.xxx, -clampResult235 );
				float4 Decal248 = ( _ColorDecal * float4( desaturateVar203 , 0.0 ) );
				float DecalOpacity251 = _ColorDecal.a;
				float DecalMask182 = ( tex2DNode181.a * DecalOpacity251 );
				float4 lerpResult183 = lerp( temp_output_303_0 , Decal248 , DecalMask182);
				float4 AlbedoAmbient117 = lerpResult183;
				
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float lerpResult68 = lerp( -3.0 , 0.0 , _FalloffOpacityIntensity);
				float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode25 = ( lerpResult68 + _PowerFalloffOpacity * pow( 1.0 - fresnelNdotV25, (( 1.0 + -_Opacity ) + (1.0 - 0.0) * (_Opacity - ( 1.0 + -_Opacity )) / (1.0 - 0.0)) ) );
				float clampResult45 = clamp( (( _Invert )?( ( 1.0 - fresnelNode25 ) ):( fresnelNode25 )) , 0.0 , 1.0 );
				float AlbedoA250 = tex2DNode76.a;
				float2 uv0_MetallicGlossMap = IN.ase_texcoord2.xy * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
				float temp_output_2_0_g7 = uv0_MetallicGlossMap.x;
				float temp_output_21_0_g7 = uv0_MetallicGlossMap.y;
				float2 appendResult14_g7 = (float2(( temp_output_2_0_g7 * GlobalTilingX281 ) , ( temp_output_21_0_g7 * GlobalTilingY282 )));
				float2 appendResult13_g7 = (float2(( temp_output_2_0_g7 + GlobalOffsetX493 ) , ( temp_output_21_0_g7 + GlobalOffsetY496 )));
				float4 tex2DNode123 = tex2D( _MetallicGlossMap, ( appendResult14_g7 + appendResult13_g7 ) );
				float RougnessA370 = tex2DNode123.a;
				float lerpResult189 = lerp( (( _UseSmoothness )?( ( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) * RougnessA370 ) ):( (( _UseAlbedoA )?( ( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) * (( _InvertAlbedoA )?( ( 1.0 - AlbedoA250 ) ):( AlbedoA250 )) ) ):( (( _FalloffOpacity )?( clampResult45 ):( ( 1.0 - _Opacity ) )) )) )) , 1.0 , DecalMask182);
				float Opacity87 = lerpResult189;
				
				
				float3 Albedo = AlbedoAmbient117.rgb;
				float Alpha = Opacity87;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}
		
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}