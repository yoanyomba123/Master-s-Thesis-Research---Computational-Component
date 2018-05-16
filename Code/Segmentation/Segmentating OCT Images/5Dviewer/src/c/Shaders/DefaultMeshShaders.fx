cbuffer VSConstantBuffer : register( b0 )
{
	matrix World;
	matrix View;
	matrix Projection;
	float4 depthPeelPlanes;
};

cbuffer PSConstantBuffer : register( b1 )
{
	float4 color;
	float4 colorModifier;
};

struct VS_OUTPUT
{
	float4 Pos : SV_POSITION;
	float3 TextureUV : TEXCOORD0;
	float3 Normal : NORMAL;
	float4 clipPlane[2] : SV_ClipDistance;
};

struct PS_OUTPUT
{
	float4 color : SV_TARGET;
	float depth : SV_DEPTH;
};

VS_OUTPUT DefaultMeshVertexShader( float4 Pos : POSITION,  float3 TextureUV : TEXCOORD, float3 Normal : NORMAL )
{
	VS_OUTPUT output = (VS_OUTPUT)0;

	output.TextureUV = TextureUV; 

	output.Pos = mul( Pos, World );

	output.clipPlane[0] = float4(0,0,0, output.Pos.z-depthPeelPlanes.x);
	output.clipPlane[1] = float4(0,0,0, depthPeelPlanes.y-output.Pos.z);

	output.Pos = mul( output.Pos, View );
	output.Pos = mul( output.Pos, Projection );

	output.Normal = mul( Normal, World );

	return output;
}

PS_OUTPUT DefaultMeshPixelShader( VS_OUTPUT input )
{ 
	PS_OUTPUT output;
	float4 mainLightDir = float4(-0.5774,-0.5774,0.5774,0);
	float lightInt = 0.7*dot(-input.Normal,mainLightDir);

	lightInt = saturate(lightInt) + 0.3;

	float3 cval = color*lightInt;

	output.color = float4(cval.x, cval.y, cval.z, color.w) * colorModifier;
	output.depth = input.Pos.z;

	return output;
}
