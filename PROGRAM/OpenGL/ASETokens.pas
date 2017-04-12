unit ASETokens;

interface

{*** TOP-LEVEL TOKENS *********************************************************}

const
  ASE_MAGIC                     = '*3DSMAX_ASCIIEXPORT';
  ASE_COMMENT                   = '*COMMENT';
  ASE_SCENE                     = '*SCENE';
  ASE_MATERIAL_LIST             = '*MATERIAL_LIST';
  ASE_GEOMOBJECT                = '*GEOMOBJECT';
  ASE_GROUP                     = '*GROUP';

{*** SCENE TOKENS *************************************************************}

const
  ASE_SCENE_FILENAME            = '*SCENE_FILENAME';
  ASE_SCENE_FIRSTFRAME          = '*SCENE_FIRSTFRAME';
  ASE_SCENE_LASTFRAME           = '*SCENE_LASTFRAME';
  ASE_SCENE_FRAMESPEED          = '*SCENE_FRAMESPEED';
  ASE_SCENE_TICKSPERFRAME       = '*SCENE_TICKSPERFRAME';
  ASE_SCENE_BACKGROUND_STATIC   = '*SCENE_BACKGROUND_STATIC';
  ASE_SCENE_AMBIENT_STATIC      = '*SCENE_AMBIENT_STATIC';

{*** MATERIAL_LIST TOKENS *****************************************************}

const
  ASE_MATERIAL_COUNT            = '*MATERIAL_COUNT';
  ASE_MATERIAL                  = '*MATERIAL';

{*** MATERIAL TOKENS **********************************************************}

const
  ASE_MATERIAL_NAME             = '*MATERIAL_NAME';
  ASE_MATERIAL_CLASS            = '*MATERIAL_CLASS';
  ASE_MATERIAL_AMBIENT          = '*MATERIAL_AMBIENT';
  ASE_MATERIAL_DIFFUSE          = '*MATERIAL_DIFFUSE';
  ASE_MATERIAL_SPECULAR         = '*MATERIAL_SPECULAR';
  ASE_MATERIAL_SHINE            = '*MATERIAL_SHINE';
  ASE_MATERIAL_SHINESTRENGTH    = '*MATERIAL_SHINESTRENGTH';
  ASE_MATERIAL_TRANSPARENCY     = '*MATERIAL_TRANSPARENCY';
  ASE_MATERIAL_WIRESIZE         = '*MATERIAL_WIRESIZE';
  ASE_MATERIAL_SHADING          = '*MATERIAL_SHADING';
  ASE_MATERIAL_XP_FALLOFF       = '*MATERIAL_XP_FALLOFF';
  ASE_MATERIAL_SELFILLUM        = '*MATERIAL_SELFILLUM';
  ASE_MATERIAL_FALLOFF          = '*MATERIAL_FALLOFF';
  ASE_MATERIAL_XP_TYPE          = '*MATERIAL_XP_TYPE';
  ASE_MATERIAL_MAP_AMBIENT      = '*MAP_AMBIENT';
  ASE_MATERIAL_MAP_DIFFUSE      = '*MAP_DIFFUSE';
  ASE_MATERIAL_MAP_SPECULAR     = '*MAP_SPECULAR';
  ASE_MATERIAL_MAP_SHINE        = '*MAP_SHINE';
  ASE_MATERIAL_MAP_SHINESTRENGTH = '*MAP_SHINESTRENGTH';
  ASE_MATERIAL_MAP_SELFILLUM    = '*MAP_SELFILLUM';
  ASE_MATERIAL_MAP_OPACITY      = '*MAP_OPACITY';
  ASE_MATERIAL_MAP_FILTERCOLOR  = '*MAP_FILTERCOLOR';
  ASE_MATERIAL_MAP_BUMP         = '*MAP_BUMP';
  ASE_MATERIAL_MAP_REFLECT      = '*MAP_REFLECT';
  ASE_MATERIAL_MAP_REFRACT      = '*MAP_REFRACT';

  ASE_MATERIAL_NUMSUBMTLS       = '*NUMSUBMTLS';
  ASE_MATERIAL_SUBMATERIAL      = '*SUBMATERIAL';

{*** MAP TOKENS ***************************************************************}

const
  ASE_MAP_NAME                  = '*MAP_NAME';
  ASE_MAP_CLASS                 = '*MAP_CLASS';
  ASE_MAP_SUBNO                 = '*MAP_SUBNO';
  ASE_MAP_AMOUNT                = '*MAP_AMOUNT';
  ASE_MAP_BITMAP                = '*BITMAP';
  ASE_MAP_TYPE                  = '*MAP_TYPE';
  ASE_MAP_UVW_U_OFFSET          = '*UVW_U_OFFSET';
  ASE_MAP_UVW_V_OFFSET          = '*UVW_V_OFFSET';
  ASE_MAP_UVW_U_TILING          = '*UVW_U_TILING';
  ASE_MAP_UVW_V_TILING          = '*UVW_V_TILING';
  ASE_MAP_UVW_ANGLE             = '*UVW_ANGLE';
  ASE_MAP_UVW_BLUR              = '*UVW_BLUR';
  ASE_MAP_UVW_BLUR_OFFSET       = '*UVW_BLUR_OFFSET';
  ASE_MAP_UVW_NOISE_AMT         = '*UVW_NOUSE_AMT';
  ASE_MAP_UVW_NOISE_SIZE        = '*UVW_NOISE_SIZE';
  ASE_MAP_UVW_NOISE_LEVEL       = '*UVW_NOISE_LEVEL';
  ASE_MAP_UVW_NOISE_PHASE       = '*UVW_NOISE_PHASE';
  ASE_MAP_BITMAP_FILTER         = '*BITMAP_FILTER';

{*** GEOMOBJECT TOKENS ********************************************************}

const
  ASE_GEOMOBJECT_NODE_NAME      = '*NODE_NAME';
  ASE_GEOMOBJECT_NODE_TM        = '*NODE_TM';
  ASE_GEOMOBJECT_MESH           = '*MESH';
  ASE_GEOMOBJECT_PROP_MOTIONBLUR = '*PROP_MOTIONBLUR';
  ASE_GEOMOBJECT_PROP_CASTSHADOW = '*PROP_CASTSHADOW';
  ASE_GEOMOBJECT_PROP_RECVSHADOW = '*PROP_RECVSHADOW';
  ASE_GEOMOBJECT_MATERIAL_REF   = '*MATERIAL_REF';

{*** NODE_TM TOKENS ***********************************************************}

const
  ASE_NODE_TM_NODE_NAME         = '*NODE_NAME';
  ASE_NODE_TM_INHERIT_POS       = '*INHERIT_POS';
  ASE_NODE_TM_INHERIT_ROT       = '*INHERIT_ROT';
  ASE_NODE_TM_INHERIT_SCL       = '*INHERIT_SCL';
  ASE_NODE_TM_TM_ROW0           = '*TM_ROW0';
  ASE_NODE_TM_TM_ROW1           = '*TM_ROW1';
  ASE_NODE_TM_TM_ROW2           = '*TM_ROW2';
  ASE_NODE_TM_TM_ROW3           = '*TM_ROW3';
  ASE_NODE_TM_TM_POS            = '*TM_POS';
  ASE_NODE_TM_TM_ROTAXIS        = '*TM_ROTAXIS';
  ASE_NODE_TM_TM_ROTANGLE       = '*TM_ROTANGLE';
  ASE_NODE_TM_TM_SCALE          = '*TM_SCALE';
  ASE_NODE_TM_TM_SCALEAXIS      = '*TM_SCALEAXIS';
  ASE_NODE_TM_TM_SCALEAXISANG   = '*TM_SCALEAXISANG';

{*** MESH TOKENS **************************************************************}

const
  ASE_MESH_TIMEVALUE            = '*TIMEVALUE';
  ASE_MESH_NUMVERTEX            = '*MESH_NUMVERTEX';
  ASE_MESH_NUMFACES             = '*MESH_NUMFACES';
  ASE_MESH_VERTEX_LIST          = '*MESH_VERTEX_LIST';
  ASE_MESH_FACE_LIST            = '*MESH_FACE_LIST';
  ASE_MESH_NUMTVERTEX           = '*MESH_NUMTVERTEX';
  ASE_MESH_NUMCVERTEX           = '*MESH_NUMCVERTEX';
  ASE_MESH_NORMALS              = '*MESH_NORMALS';
  ASE_MESH_TVERTLIST            = '*MESH_TVERTLIST';
  ASE_MESH_NUMTVFACES           = '*MESH_NUMTVFACES';
  ASE_MESH_TFACELIST            = '*MESH_TFACELIST';
  ASE_MESH_CVERTLIST            = '*MESH_CVERTLIST';
  ASE_MESH_CFACELIST            = '*MESH_CFACELIST';

{*** MESH_VERTEX_LIST TOKENS **************************************************}

const
  ASE_MESH_VERTEX               = '*MESH_VERTEX';

{*** MESH_TVERTLIST TOKENS ****************************************************}

const
  ASE_MESH_TVERT                = '*MESH_TVERT';

{*** MESH_CVERTLIST TOKENS ****************************************************}

const
  ASE_MESH_VERTCOL              = '*MESH_VERTCOL';

{*** MESH_TFACELIST TOKENS ****************************************************}

const
  ASE_MESH_TFACE                = '*MESH_TFACE';

{*** MESH_CFACELIST TOKENS ****************************************************}

const
  ASE_MESH_CFACE                = '*MESH_CFACE';

{*** MESH_FACE_LIST TOKENS ****************************************************}

const
  ASE_MESH_FACE                 = '*MESH_FACE';
  ASE_MESH_SMOOTHING            = '*MESH_SMOOTHING';
  ASE_MESH_MTLID                = '*MESH_MTLID';

{*** MESH_NORMALS TOKENS ******************************************************}

const
  ASE_MESH_FACENORMAL           = '*MESH_FACENORMAL';
  ASE_MESH_VERTEXNORMAL         = '*MESH_VERTEXNORMAL';

implementation

end.
