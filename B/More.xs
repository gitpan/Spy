/* $Id: More.xs,v 1.10 2003/03/03 00:12:58 xmath Exp $ */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

static char *svclassnames[] = {
    "B::NULL",
    "B::IV",
    "B::NV",
    "B::RV",
    "B::PV",
    "B::PVIV",
    "B::PVNV",
    "B::PVMG",
    "B::BM",
    "B::PVLV",
    "B::AV",
    "B::HV",
    "B::CV",
    "B::GV",
    "B::FM",
    "B::IO",
};

typedef SV	*B__SV;
typedef SV	*B__IV;
typedef SV	*B__PV;
typedef SV	*B__NV;
typedef SV	*B__PVMG;
typedef SV	*B__PVLV;
typedef SV	*B__BM;
typedef SV	*B__RV;
typedef AV	*B__AV;
typedef HV	*B__HV;
typedef CV	*B__CV;
typedef GV	*B__GV;
typedef IO	*B__IO;

typedef PERL_SI	*B__SI;

typedef SV	*B__SPECIAL;

typedef MAGIC	*B__MAGIC;


#define MY_CXT_KEY "B::More::_guts" XS_VERSION

typedef struct {
	SV *	x_specialsv_list[7];
} my_cxt_t;

START_MY_CXT

#define specialsv_list	(MY_CXT.x_specialsv_list)

static SV *get_special(IV iv) {
	dMY_CXT;
	if (iv >= 0 && iv < sizeof(specialsv_list) / sizeof(SV *))
		return specialsv_list[iv];
	return NULL;
}

static SV *make_sv_object(pTHX_ SV *arg, SV *sv) {
	char	*type = 0;
	IV	iv;
	dMY_CXT;
	
	for (iv = 0; iv < sizeof(specialsv_list) / sizeof(SV *); iv++) {
		if (specialsv_list[iv] == sv) {
			type = "B::SPECIAL";
			break;
		}
	}
	if (!type) {
		type = svclassnames[SvTYPE(sv)];
		iv = PTR2IV(sv);
	}
	sv_setiv(newSVrv(arg, type), iv);
	return arg;
}


MODULE = B::More
PROTOTYPES: DISABLE

BOOT:
{
	HV *stash = gv_stashpvn("B::More", 7, TRUE);
	MY_CXT_INIT;
	specialsv_list[0] = Nullsv;
	specialsv_list[1] = &PL_sv_undef;
	specialsv_list[2] = &PL_sv_yes;
	specialsv_list[3] = &PL_sv_no;
	specialsv_list[4] = pWARN_ALL;
	specialsv_list[5] = pWARN_NONE;
	specialsv_list[6] = pWARN_STD;
	newCONSTSUB(stash, "SVs_PADBUSY", newSViv(SVs_PADBUSY)); 
	newCONSTSUB(stash, "SVs_OBJECT",  newSViv(SVs_OBJECT)); 
}


MODULE = B::More	PACKAGE = B::SV		PREFIX = SV_	

SV *
SV_svref(sv)
	B::SV	sv
    CODE:
	RETVAL = sv ? newRV(sv) : SvREFCNT_inc(&PL_sv_undef);
    OUTPUT:
	RETVAL

void
SV_chflags(sv, set, clear)
	B::SV	sv
	U32	set
	U32	clear
    CODE:
	SvFLAGS(sv) |= set;
	SvFLAGS(sv) &= ~clear;

void
SV_bless(sv, stash)
	B::SV	sv
	B::HV	stash
    CODE:
	sv_bless(sv_2mortal(newRV_inc(sv)), stash);

void
SV_curse(sv)
	B::SV	sv
    CODE:
	if (SvREADONLY(sv))
		croak(PL_no_modify);
        if (SvOBJECT(sv)) {
		if (SvTYPE(sv) != SVt_PVIO)
			--PL_sv_objcount;
		SvAMAGIC_off(sv);
		SvOBJECT_off(sv);
		SvREFCNT_dec(SvSTASH(sv));
		SvSTASH(sv) = Nullhv;
		if (SvSMAGICAL(sv) && (mg_find(sv, PERL_MAGIC_ext)
					|| mg_find(sv, PERL_MAGIC_uvar)) )
			mg_set(sv);
	}


MODULE = B::More	PACKAGE = B::SPECIAL	PREFIX = SPECIAL_

SV *
SPECIAL_svref(sv)
	B::SPECIAL	sv
    CODE:
	RETVAL = sv ? newRV(sv) : SvREFCNT_inc(&PL_sv_undef);
    OUTPUT:
	RETVAL


MODULE = B::More	PACKAGE = B::SV

U32
SvTYPE(sv)
	B::SV	sv


MODULE = B::More	PACKAGE = B::More

UV
SvUVX(sv) 
        B::IV   sv


MODULE = B::More	PACKAGE = B::IV		PREFIX = SV_

void
SV_setIVX(sv, value)
	B::IV	sv
	SV	*value
    CODE:
	SvOOK_off(sv);
	SvIVX(sv) = SvIV(value);


MODULE = B::More	PACKAGE = B::NV		PREFIX = SV_

void
SV_setNVX(sv, value)
	B::NV	sv
	SV	*value
    CODE:
	SvNVX(sv) = SvNV(value);


MODULE = B::More	PACKAGE = B::PV		PREFIX = SV_

void
SV_setPVX(sv, value)
	B::PV	sv
	SV	*value
    PREINIT:
	STRLEN	len;
	char	*src, *dst;
    CODE:
	src = SvPV(value, len);
	SvGROW(sv, len + 1);
	dst = SvPVX(sv);
	if (SvUTF8(value))
		SvUTF8_on(sv);
	else
		SvUTF8_off(sv);
	Move(src, dst, len, char);
	dst[len] = 0;
	SvCUR(sv) = len;


MODULE = B::More	PACKAGE = B::SV		PREFIX = Sv

void
SvUPGRADE(sv, type)
	B::SV	sv
	U32	type

bool
SvTAINTED(sv)
	B::SV	sv

void
SvTAINTED_on(sv)
	B::SV	sv

void
SvTAINTED_off(sv)
	B::SV	sv


MODULE = B::More	PACKAGE = B::SV		PREFIX = sv_

void
sv_force_normal(sv)
	B::SV	sv


MODULE = B::More	PACKAGE = B::RV		PREFIX = sv_

void
sv_rvweaken(rv)
	B::RV	rv


MODULE = B::More	PACKAGE = B::AV		PREFIX = AV_

void
AV_store(av, index, val)
	B::AV	av
	I32	index
	B::SV	val
    CODE:
	if (!av_store(av, index, SvREFCNT_inc(val)))
		SvREFCNT_dec(val);

void
AV_push(av, val)
	B::AV	av
	B::SV	val
    CODE:
	av_push(av, SvREFCNT_inc(val));


MODULE = B::More	PACKAGE = B::AV		PREFIX = av_

void
av_unshift(av, num)
	B::AV	av
	I32	num

void
av_extend(av, index)
	B::AV	av
	I32	index


MODULE = B::More	PACKAGE = B::SI		PREFIX = SI_

B::SI
SI_new(class, stitems, cxitems)
	SV	*class
	I32	stitems
	I32	cxitems
    CODE:
	RETVAL = new_stackinfo(stitems, cxitems);
    OUTPUT:
	RETVAL

void
SI_nuke(si)
	B::SI	si
    CODE:
	if (si->si_next) si->si_next->si_prev = si->si_prev;
	if (si->si_prev) si->si_prev->si_next = si->si_next;
	SvREFCNT_dec(si->si_stack);
	Safefree(si->si_cxstack);
	Poison(si, 1, PERL_SI);
	Safefree(si);

#define SI_STACK(si)	((si)->si_stack)
#define SI_CXIX(si)	((si)->si_cxix)
#define SI_CXMAX(si)	((si)->si_cxmax)
#define SI_TYPE(si)	((si)->si_type)
#define SI_PREV(si)	((si)->si_prev)
#define SI_NEXT(si)	((si)->si_next)
#define SI_CXTYPE(si,i)	((si)->si_cxstack[i].cx_type)

B::AV
SI_STACK(si)
	B::SI	si

I32
SI_CXIX(si)
	B::SI	si

I32
SI_CXMAX(si)
	B::SI	si

I32
SI_TYPE(si)
	B::SI	si

B::SI
SI_NEXT(si)
	B::SI	si

B::SI
SI_PREV(si)
	B::SI	si

I32
SI_CXTYPE(si, index)
	B::SI	si
	I32	index


MODULE = B::More	PACKAGE = B		PREFIX = B_

B::HV
B_defstash()
    CODE:
	RETVAL = PL_defstash;
    OUTPUT:
	RETVAL

B::HV
B_curstash()
    CODE:
	RETVAL = PL_curstash;
    OUTPUT:
	RETVAL

B::SI
B_curstackinfo()
    CODE:
	RETVAL = PL_curstackinfo;
    OUTPUT:
	RETVAL
