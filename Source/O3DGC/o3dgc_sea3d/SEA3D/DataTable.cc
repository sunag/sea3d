#include "DataTable.h"

const char* DataTable::BLEND_MODE[] = {
	"normal","add","subtract","multiply","dividing","mix","alpha","screen","darken",
	"overlay","colorburn","linearburn","lighten","colordodge","lineardodge",
	"softlight","hardlight","pinlight","spotlight","spotlightblend","hardmix",
	"average","difference","exclusion","hue","saturation","color","value"
};

const char* DataTable::INTERPOLATION_TABLE[] = {
	"normal","linear",
	"sine.in","sine.out","sine.inout",
	"cubic.in","cubic.out","cubic.inout",
	"quint.in","quint.out","quint.inout",
	"circ.in","circ.out","circ.inout",
	"back.in","back.out","back.inout",
	"quad.in","quad.out","quad.inout",
	"quart.in","quart.out","quart.inout",
	"expo.in","expo.out","expo.inout",
	"elastic.in","elastic.out","elastic.inout",
	"bounce.in","bounce.out","bounce.inout"
};