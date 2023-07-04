Shader "Unlit/grass"
{
    Properties
    {
        _ScrollTex ("Texture!", 2D) = "white" {}
        _WaveAmp ("Displacement Amplification", Range (0,1)) = 0.25
        _Speed ("Wave Speed" , Range (0, 1)) = 0.1
        _ColorA ("Color A", Color) = (1,1,1,1)
        _ColorB ("Color B", Color) = (0,0,0,1)
        _AOColor ("Ambient Occlusion", Color) = (1, 1, 1)
        _TipColor ("Tip Color", Color) = (1, 1, 1)
        _Height("Grass Height", range(0,5)) = 0.0
		_Width("Grass Width", range(0, 5)) = 0.0
        _Scale ("Scale", range(0.0, 2.0)) = 0.0
        _Droop ("Droop", range(0.0, 2)) = 0.0
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        

        Pass
        {

             Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           

            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float _WaveAmp, _Speed, _Scale, _Height, _Width, _Droop;
            float4 _ColorA, _ColorB, _AOColor, _TipColor;
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float vertexPos : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float vertexPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _ScrollTex; 
            

            v2f vert (appdata v)
            {
                v2f o;
                //getting worldspace of vertex mesh
                o.worldPos = mul( UNITY_MATRIX_M, v.vertex);
                float2 topDownProjection = o.worldPos.xz;
                //scrolling texture of pearlin noise in worldspace
                float4 scrollTex = _WaveAmp * v.uv.y * v.uv.y * tex2Dlod(_ScrollTex, float4(topDownProjection.x, topDownProjection.y + _Time.y * _Speed,0,0));

                //Stretches the mesh upwards
                v.vertex.y += _Height * v.uv.y;
                
                //bendy over time 
                float wave = cos((_Time.y * _Speed) * TAU * 2 );


                //bend the mesh forward
                v.vertex.z += (scrollTex * wave)*2  ;
                
                

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //o.vertexPos = 0.5 - v.vertexPos;
    
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_ScrollTex, i.uv.y + _Time.y * _Speed);
               

                float4 gradient = lerp(_ColorA, _ColorB, -i.uv.x);
                

                
                return float4(i.uv,0,0);
            }
            ENDCG
        }
    }
}
