Shader "PostEffect/Bloom"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
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
		};

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _MainTex_TexelSize;
		sampler2D _SourceTex;
		float _Threshold;
		float _Intensity;

		// メインテクスチャからサンプリングしてRGBのみを返す
		half3 sampleMain(float2 uv) 
		{
			return tex2D(_MainTex, uv).rgb;
		}

		// 対角線上の4点からサンプリングした色の平均値を返す
		half3 sampleBox(float2 uv, float delta) 
		{
			float4 offset = _MainTex_TexelSize.xyxy * float2(-delta, delta).xxyy;
			half3 sum = sampleMain(uv + offset.xy) + sampleMain(uv + offset.zy) + sampleMain(uv + offset.xw) + sampleMain(uv + offset.zw);
			return sum * 0.25;
		}

		// 明度を返す
		half brightness(half3 color) 
		{
			return max(color.r, max(color.g, color.b));
		}

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		ENDCG


		Cull Off
		ZTest Always
		ZWrite Off

		Tags { "RenderType" = "Opaque" }

		// 適用するピクセル抽出用のパス
		Pass
		{
			CGPROGRAM

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = 1;
				col.rgb = sampleBox(i.uv, 1.0);
				half br = brightness(col.rgb);

				// 明度がThresholdより大きいピクセルだけブルームの対象とする
				half contribution = max(0, br - _Threshold);
				contribution /= max(br, 0.00001);

				return col * contribution;
			}

			ENDCG
		}

		// ダウンサンプリング用のパス
		Pass
		{
			CGPROGRAM

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = 1;
				col.rgb = sampleBox(i.uv, 1.0);
				return col;
			}

			ENDCG
		}

		// アップサンプリング用のパス
		Pass
		{
			Blend One One

			CGPROGRAM

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = 1;
				col.rgb = sampleBox(i.uv, 0.5);
				return col;
			}

			ENDCG
		}

		// 3: 最後の一回のアップサンプリング用のパス
		Pass
		{
			CGPROGRAM

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = tex2D(_SourceTex, i.uv);
				col.rgb += sampleBox(i.uv, 0.5) * _Intensity;
				return col;
			}

			ENDCG
		}
	}
}