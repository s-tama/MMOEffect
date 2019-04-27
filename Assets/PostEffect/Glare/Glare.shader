Shader "PostEffect/Glare"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)

		_Threshold("Threshold", Float) = 1
		_Intensity("Intensity", Float) = 1
		_Attenuation("Attenuation", Float) = 1
    }
    SubShader
    {
		// 共通で使用
		CGINCLUDE
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
			float2 uvOffset : TEXCOORD1;
			float pathFactor : TEXCOORD2;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;	// テクスチャのピクセルサイズ
		float4 _Color;
		float _Threshold;		// 閾値
		float _Intensity;		// 光の強さ
		float _Attenuation;		// 減衰
		int3 _Params;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			o.pathFactor = pow(4, _Params.z);
			o.uvOffset = float2(_Params.x, _Params.y) * _MainTex_TexelSize.xy * o.pathFactor;
			return o;
		}
		ENDCG


        Tags { "RenderType"="Opaque" }
        LOD 100

		Cull Off
		ZTest Always
		ZWrite Off


		// 明度抽出用パス
        Pass
        {
            CGPROGRAM
            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv) * _Color;
				float brightness = max(col.r, max(col.g, col.b));
				float contribution = max(0, brightness - _Threshold);
                return col * contribution;
            }
            ENDCG
        }

		// スター生成パス
		Pass
		{
			CGPROGRAM
			float4 frag(v2f i) : SV_Target
			{
				float4 col = float4(0, 0, 0, 1);

				float2 uv = i.uv;
				for (int j = 0; j < 4; j++)
				{
					col.rgb += tex2D(_MainTex, uv) * pow(_Attenuation, j * i.pathFactor);
					uv += i.uvOffset;
				}

				return col;
			}
			ENDCG
		}

		// 加算合成パス
		Pass
		{
			Blend One One
			ColorMask RGB

			CGPROGRAM
			float4 frag(v2f i) : SV_Target
			{
				return tex2D(_MainTex, i.uv) * _Color * _Intensity;
			}
			ENDCG
		}
    }
}
