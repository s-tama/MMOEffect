﻿//
// MagicCircle0.shader
// Actor: Tama
// Date: 2019/04/22(月)
//

// 魔法陣を演出する
// 生成魔法陣数3
Shader "Performance/MagicCircle3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType"="Transparent" 
			"Queue"="Transparent"
			"IgnoreProjector" = "True"
		}
        LOD 100

		Blend SrcAlpha OneMinusSrcAlpha

		// 第一魔法陣
        Pass
        {
			ZWrite Off
			Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "MyCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
            };

            sampler2D _MainTex;
			float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;

				// 拡大させる
				float s = 0;
				s += _Time*40;
				if (s >= 1) s = 1;
				o.vertex.xyz = scale(v.vertex.xyz, float3(s, 1, s));

				// 回転させる
				float angle = _Time * 10;
				o.vertex.xyz = rotate(o.vertex.xyz, angle, float3(0, 1, 0));

				// 再計算する
                o.vertex = UnityObjectToClipPos(o.vertex);
				o.uv = v.uv;
				o.normal = v.normal;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv) * _Color;
				col.a = (toGray(col) < 0.2) ? 1 : 0;
                return col*5;
            }
            ENDCG
        }

		// 第二魔法陣
		Pass
		{
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "MyCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _Color;

			v2f vert(appdata v)
			{
				v2f o;

				// 拡大させる
				float s = 0;
				s += _Time * 50;
				if (s >= 3) s = 3;
				o.vertex.xyz = scale(v.vertex.xyz, float3(s, 1, s));

				// 回転させる
				float angle = -_Time * 10;
				o.vertex.xyz = rotate(o.vertex.xyz, angle, float3(0, 1, 0));

				// 移動させる
				o.vertex.xyz += v.normal * 20;

				o.vertex = UnityObjectToClipPos(o.vertex);
				o.uv = v.uv;
				o.normal = UnityObjectToWorldNormal(v.normal);

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv) * _Color;
				col.a = (toGray(col) < 0.2) ? 1 : 0;
				return col*5;
			}
			ENDCG
		}

		// 第三魔法陣
		Pass
		{
			ZWrite Off
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "MyCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _Color;

			v2f vert(appdata v)
			{
				v2f o;

				// 拡大させる
				float s = 0;
				s += _Time * 100;
				if (s >= 6) s = 6;
				o.vertex.xyz = scale(v.vertex.xyz, float3(s, 1, s));

				// 回転させる
				float angle = _Time * 10;
				o.vertex.xyz = rotate(o.vertex.xyz, angle, float3(0, 1, 0));

				// 移動させる
				o.vertex.xyz += v.normal * 40;

				o.vertex = UnityObjectToClipPos(o.vertex);
				o.uv = v.uv;
				o.normal = UnityObjectToWorldNormal(v.normal);

				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv) * _Color;
				col.a = (toGray(col) < 0.2) ? 1 : 0;
				return col * 5;
			}
			ENDCG
		}
    }
}
