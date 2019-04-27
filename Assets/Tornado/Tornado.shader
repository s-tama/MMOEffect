//
// Tornado.shader
// Actor: Tamamura Shuuki
// Date: 2019/04/26(金)
//

// 竜巻を起こすエフェクト
Shader "Performance/Tornado"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Tags
		{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}
		LOD 100

		// 共通で使用
		CGINCLUDE
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"
		#include "MyCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		ENDCG

		
		Cull Off
		//ZTest Always
		//ZWrite Off

		// 0パス目
        Pass
        {
			//Blend One One

            CGPROGRAM
            v2f vert (appdata v)
            {
                v2f o;
				// 拡大する
				o.vertex.xyz = scale(v.vertex.xyz, float3(2, 2, 2));
                o.vertex = UnityObjectToClipPos(o.vertex);
				o.uv = v.uv;
                return o;
            }

            float frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }

		// 1パス目
		Pass
		{
			//Blend One One

			CGPROGRAM
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float frag(v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
    }
}
