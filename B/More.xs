/* $Id: More.xs,v 1.13 2003/03/06 16:30:16 xmath Exp $ */

/*	More.xs
 *
 *	Copyright (c) 2003 Matthijs van Duin
 *
 *	Parts from B.xs which is Copyright (c) 1996 Malcolm Beattie
 *
 *      You may distribute under the terms of either the GNU General Public
 *      License or the Artistic License, as specified in the README file.
 */     

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdio.h>

/* ==== copied from B.xs ==== */

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

typedef enum {
    OPc_NULL,	/* 0 */
    OPc_BASEOP,	/* 1 */
    OPc_UNOP,	/* 2 */
    OPc_BINOP,	/* 3 */
    OPc_LOGOP,	/* 4 */
    OPc_LISTOP,	/* 5 */
    OPc_PMOP,	/* 6 */
    OPc_SVOP,	/* 7 */
    OPc_PADOP,	/* 8 */
    OPc_PVOP,	/* 9 */
    OPc_CVOP,	/* 10 */
    OPc_LOOP,	/* 11 */
    OPc_COP	/* 12 */
} opclass;

static char *opclassnames[] = {
    "B::NULL",
    "B::OP",
    "B::UNOP",
    "B::BINOP",
    "B::LOGOP",
    "B::LISTOP",
    "B::PMOP",
    "B::SVOP",
    "B::PADOP",
    "B::PVOP",
    "B::CVOP",
    "B::LOOP",
    "B::COP"	
};

/* ==== end of copied from B.xs ==== */

/* (modified part) */

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

/* ==== copied from B.xs ==== */

static opclass
cc_opclass(pTHX_ OP *o)
{
    if (!o)
	return OPc_NULL;

    if (o->op_type == 0)
	return (o->op_flags & OPf_KIDS) ? OPc_UNOP : OPc_BASEOP;

    if (o->op_type == OP_SASSIGN)
	return ((o->op_private & OPpASSIGN_BACKWARDS) ? OPc_UNOP : OPc_BINOP);

#ifdef USE_ITHREADS
    if (o->op_type == OP_GV || o->op_type == OP_GVSV || o->op_type == OP_AELEMFAST)
	return OPc_PADOP;
#endif

    switch (PL_opargs[o->op_type] & OA_CLASS_MASK) {
    case OA_BASEOP:
	return OPc_BASEOP;

    case OA_UNOP:
	return OPc_UNOP;

    case OA_BINOP:
	return OPc_BINOP;

    case OA_LOGOP:
	return OPc_LOGOP;

    case OA_LISTOP:
	return OPc_LISTOP;

    case OA_PMOP:
	return OPc_PMOP;

    case OA_SVOP:
	return OPc_SVOP;

    case OA_PADOP:
	return OPc_PADOP;

    case OA_PVOP_OR_SVOP:
        /*
         * Character translations (tr///) are usually a PVOP, keeping a 
         * pointer to a table of shorts used to look up translations.
         * Under utf8, however, a simple table isn't practical; instead,
         * the OP is an SVOP, and the SV is a reference to a swash
         * (i.e., an RV pointing to an HV).
         */
	return (o->op_private & (OPpTRANS_TO_UTF|OPpTRANS_FROM_UTF))
		? OPc_SVOP : OPc_PVOP;

    case OA_LOOP:
	return OPc_LOOP;

    case OA_COP:
	return OPc_COP;

    case OA_BASEOP_OR_UNOP:
	/*
	 * UNI(OP_foo) in toke.c returns token UNI or FUNC1 depending on
	 * whether parens were seen. perly.y uses OPf_SPECIAL to
	 * signal whether a BASEOP had empty parens or none.
	 * Some other UNOPs are created later, though, so the best
	 * test is OPf_KIDS, which is set in newUNOP.
	 */
	return (o->op_flags & OPf_KIDS) ? OPc_UNOP : OPc_BASEOP;

    case OA_FILESTATOP:
	/*
	 * The file stat OPs are created via UNI(OP_foo) in toke.c but use
	 * the OPf_REF flag to distinguish between OP types instead of the
	 * usual OPf_SPECIAL flag. As usual, if OPf_KIDS is set, then we
	 * return OPc_UNOP so that walkoptree can find our children. If
	 * OPf_KIDS is not set then we check OPf_REF. Without OPf_REF set
	 * (no argument to the operator) it's an OP; with OPf_REF set it's
	 * an SVOP (and op_sv is the GV for the filehandle argument).
	 */
	return ((o->op_flags & OPf_KIDS) ? OPc_UNOP :
#ifdef USE_ITHREADS
		(o->op_flags & OPf_REF) ? OPc_PADOP : OPc_BASEOP);
#else
		(o->op_flags & OPf_REF) ? OPc_SVOP : OPc_BASEOP);
#endif
    case OA_LOOPEXOP:
	/*
	 * next, last, redo, dump and goto use OPf_SPECIAL to indicate that a
	 * label was omitted (in which case it's a BASEOP) or else a term was
	 * seen. In this last case, all except goto are definitely PVOP but
	 * goto is either a PVOP (with an ordinary constant label), an UNOP
	 * with OPf_STACKED (with a non-constant non-sub) or an UNOP for
	 * OP_REFGEN (with goto &sub) in which case OPf_STACKED also seems to
	 * get set.
	 */
	if (o->op_flags & OPf_STACKED)
	    return OPc_UNOP;
	else if (o->op_flags & OPf_SPECIAL)
	    return OPc_BASEOP;
	else
	    return OPc_PVOP;
    }
    warn("can't determine class of operator %s, assuming BASEOP\n",
	 PL_op_name[o->op_type]);
    return OPc_BASEOP;
}

static char *
cc_opclassname(pTHX_ OP *o)
{
    return opclassnames[cc_opclass(aTHX_ o)];
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

typedef OP	*B__OP;
typedef UNOP	*B__UNOP;
typedef BINOP	*B__BINOP;
typedef LOGOP	*B__LOGOP;
typedef LISTOP	*B__LISTOP;
typedef PMOP	*B__PMOP;
typedef SVOP	*B__SVOP;
typedef PADOP	*B__PADOP;
typedef PVOP	*B__PVOP;
typedef LOOP	*B__LOOP;
typedef COP	*B__COP;

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

typedef MAGIC	*B__MAGIC;

/* ==== end of copied from B.xs ==== */

typedef SV	*B__SPECIAL;
typedef PERL_SI	*B__SI;


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

#define SI_stack(si)	((si)->si_stack)
#define SI_cxix(si)	((si)->si_cxix)
#define SI_cxmax(si)	((si)->si_cxmax)
#define SI_type(si)	((si)->si_type)
#define SI_prev(si)	((si)->si_prev)
#define SI_next(si)	((si)->si_next)
#define SI_cx_type(s,i)		((s)->si_cxstack[i].cx_type)
#define SI_blk_oldsp(s,i)	((s)->si_cxstack[i].blk_oldsp)
#define SI_blk_oldcop(s,i)	((s)->si_cxstack[i].blk_oldcop)
#define SI_blk_oldretsp(s,i)	((s)->si_cxstack[i].blk_oldretsp)
#define SI_blk_oldmarksp(s,i)	((s)->si_cxstack[i].blk_oldmarksp)
#define SI_blk_oldscopesp(s,i)	((s)->si_cxstack[i].blk_oldscopesp)
#define SI_blk_oldpm(s,i)	((s)->si_cxstack[i].blk_oldpm)
#define SI_blk_gimme(s,i)	((s)->si_cxstack[i].blk_gimme)
#define SI_sb_iters(s,i)	((s)->si_cxstack[i].sb_iters)
#define SI_sb_maxiters(s,i)	((s)->si_cxstack[i].sb_maxiters)
#define SI_sb_rflags(s,i)	((s)->si_cxstack[i].sb_rflags)
#define SI_sb_oldsave(s,i)	((s)->si_cxstack[i].sb_oldsave)
#define SI_sb_once(s,i) 	((s)->si_cxstack[i].sb_once)
#define SI_sb_rxtainted(s,i)	((s)->si_cxstack[i].sb_rxtainted)
#define SI_sb_dstr(s,i) 	((s)->si_cxstack[i].sb_dstr)
#define SI_sb_targ(s,i) 	((s)->si_cxstack[i].sb_targ)
#define SI_sub_cv(s,i)		((s)->si_cxstack[i].blk_sub.cv)
#define SI_sub_gv(s,i)		((s)->si_cxstack[i].blk_sub.gv)
#define SI_sub_dfoutgv(s,i)	((s)->si_cxstack[i].blk_sub.dfoutgv)
#ifndef USE_5005THREADS
#define SI_sub_savearray(s,i)	((s)->si_cxstack[i].blk_sub.savearray)
#else
#define SI_sub_savearray(s,i)	(Nullav)
#endif
#define SI_sub_argarray(s,i)	((s)->si_cxstack[i].blk_sub.argarray)
#define SI_sub_olddepth(s,i)	((s)->si_cxstack[i].blk_sub.olddepth)
#define SI_sub_hasargs(s,i)	((s)->si_cxstack[i].blk_sub.hasargs)
#define SI_sub_lval(s,i)	((s)->si_cxstack[i].blk_sub.lval)
#define SI_eval_oldineval(s,i)	((s)->si_cxstack[i].blk_eval.old_in_eval)
#define SI_eval_oldoptype(s,i)	((s)->si_cxstack[i].blk_eval.old_op_type)
#define SI_eval_oldnamesv(s,i)	((s)->si_cxstack[i].blk_eval.old_namesv)
#define SI_eval_oldevalroot(s,i) ((s)->si_cxstack[i].blk_eval.old_eval_root)
#define SI_eval_curtext(s,i)	((s)->si_cxstack[i].blk_eval.cur_text)
#define SI_eval_cv(s,i)		((s)->si_cxstack[i].blk_eval.cv)
#define SI_loop_label(s,i)	((s)->si_cxstack[i].blk_loop.label)
#define SI_loop_resetsp(s,i)	((s)->si_cxstack[i].blk_loop.resetsp)
#define SI_loop_redoop(s,i)	((s)->si_cxstack[i].blk_loop.redo_op)
#define SI_loop_nextop(s,i)	((s)->si_cxstack[i].blk_loop.next_op)
#define SI_loop_lastop(s,i)	((s)->si_cxstack[i].blk_loop.last_op)
#ifdef USE_ITHREADS
#define SI_loop_iterdata(s,i)	PTR2UV((s)->si_cxstack[i].blk_loop.iterdata)
#define SI_loop_oldcurpad(s,i)	PTR2UV((s)->si_cxstack[i].blk_loop.oldcurpad)
#else
#define SI_loop_iterdata(s,i)	(0)
#define SI_loop_oldcurpad(s,i)	(0)
#endif
#define SI_loop_itervar(s,i)	PTR2UV(CxITERVAR(&((s)->si_cxstack[i])))
#define SI_loop_itersave(s,i)	((s)->si_cxstack[i].blk_loop.itersave)
#define SI_loop_iterlval(s,i)	((s)->si_cxstack[i].blk_loop.iterlval)
#define SI_loop_iterary(s,i)	((s)->si_cxstack[i].blk_loop.iterary)
#define SI_loop_iterix(s,i)	((s)->si_cxstack[i].blk_loop.iterix)
#define SI_loop_itermax(s,i)	((s)->si_cxstack[i].blk_loop.itermax)

B::AV
SI_stack(si)
	B::SI	si

I32
SI_cxix(si)
	B::SI	si

I32
SI_cxmax(si)
	B::SI	si

I32
SI_type(si)
	B::SI	si

B::SI
SI_next(si)
	B::SI	si

B::SI
SI_prev(si)
	B::SI	si

I32
SI_cx_type(si, index)
	B::SI	si
	I32	index

I32
SI_blk_oldsp(si, index)
	B::SI	si
	I32	index

B::COP
SI_blk_oldcop(si, index)
	B::SI	si
	I32	index

I32
SI_blk_oldretsp(si, index)
	B::SI	si
	I32	index

I32
SI_blk_oldmarksp(si, index)
	B::SI	si
	I32	index

I32
SI_blk_oldscopesp(si, index)
	B::SI	si
	I32	index

B::PMOP
SI_blk_oldpm(si, index)
	B::SI	si
	I32	index

U8
SI_blk_gimme(si, index)
	B::SI	si
	I32	index

I32
SI_sb_iters(si, index)
	B::SI	si
	I32	index

I32
SI_sb_maxiters(si, index)
	B::SI	si
	I32	index

I32
SI_sb_rflags(si, index)
	B::SI	si
	I32	index

I32
SI_sb_oldsave(si, index)
	B::SI	si
	I32	index

bool
SI_sb_once(si, index)
	B::SI	si
	I32	index

bool
SI_sb_rxtainted(si, index)
	B::SI	si
	I32	index

B::SV
SI_sb_dstr(si, index)
	B::SI	si
	I32	index

B::SV
SI_sb_targ(si, index)
	B::SI	si
	I32	index

B::CV
SI_sub_cv(si, index)
	B::SI	si
	I32	index

B::GV
SI_sub_gv(si, index)
	B::SI	si
	I32	index

B::GV
SI_sub_dfoutgv(si, index)
	B::SI	si
	I32	index

B::AV
SI_sub_savearray(si, index)
	B::SI	si
	I32	index

B::AV
SI_sub_argarray(si, index)
	B::SI	si
	I32	index

U16
SI_sub_olddepth(si, index)
	B::SI	si
	I32	index

U8
SI_sub_hasargs(si, index)
	B::SI	si
	I32	index

U8
SI_sub_lval(si, index)
	B::SI	si
	I32	index

I32
SI_eval_oldineval(si, index)
	B::SI	si
	I32	index

I32
SI_eval_oldoptype(si, index)
	B::SI	si
	I32	index

B::SV
SI_eval_oldnamesv(si, index)
	B::SI	si
	I32	index

B::OP
SI_eval_oldevalroot(si, index)
	B::SI	si
	I32	index

B::SV
SI_eval_curtext(si, index)
	B::SI	si
	I32	index

B::CV
SI_eval_cv(si, index)
	B::SI	si
	I32	index

char *
SI_loop_label(si, index)
	B::SI	si
	I32	index

I32
SI_loop_resetsp(si, index)
	B::SI	si
	I32	index

B::OP
SI_loop_redoop(si, index)
	B::SI	si
	I32	index

B::OP
SI_loop_nextop(si, index)
	B::SI	si
	I32	index

B::OP
SI_loop_lastop(si, index)
	B::SI	si
	I32	index

UV
SI_loop_iterdata(si, index)
	B::SI	si
	I32	index

UV
SI_loop_oldcurpad(si, index)
	B::SI	si
	I32	index

UV
SI_loop_itervar(si, index)
	B::SI	si
	I32	index

B::SV
SI_loop_itersave(si, index)
	B::SI	si
	I32	index

B::SV
SI_loop_iterlval(si, index)
	B::SI	si
	I32	index

B::AV
SI_loop_iterary(si, index)
	B::SI	si
	I32	index

IV
SI_loop_iterix(si, index)
	B::SI	si
	I32	index

IV
SI_loop_itermax(si, index)
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

void
B_peek(addr, count)
        UV      addr
        IV      count
    PREINIT:
	IV      i;
    PPCODE:
	if (count > 0)
		EXTEND(SP, count);
	for (i = 0; i < count; i++)
		PUSHs(sv_2mortal(newSVuv((INT2PTR(IV *, addr))[i])));

void
B_poke(addr, ...)
	UV	addr
    PREINIT:
	IV	i;
    CODE:
	(INT2PTR(UV *, addr))--;
	for (i = 1; i < items; i++)
		(INT2PTR(UV *, addr))[i] = SvUV(ST(i));

B::SV
B_readsv(addr)
	UV	addr
    CODE:
	RETVAL = *(INT2PTR(SV **, addr));
    OUTPUT:
	RETVAL

B::SV
B_swapsv(addr, sv)
	UV	addr
	B::SV	sv
    CODE:
	if ((RETVAL = *(INT2PTR(SV **, addr))))
		sv_2mortal(RETVAL);
	*(INT2PTR(SV **, addr)) = sv ? SvREFCNT_inc(sv) : Nullsv;
    OUTPUT:
	RETVAL

B::SV
B_swapsv_noinc(addr, sv)
	UV	addr
	B::SV	sv
    CODE:
	RETVAL = *(INT2PTR(SV **, addr));
	*(INT2PTR(SV **, addr)) = sv;
    OUTPUT:
	RETVAL

