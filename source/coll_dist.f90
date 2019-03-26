! ================================================================================================ !
!  Dist Module for Collimation
!  Extracted from collimation module
! ================================================================================================ !
module coll_dist

  use parpro
  use floatPrecision
  use numerical_constants

  implicit none

  ! Other Settings
  integer,                  public,  save :: cdist_logUnit  = -1
  real(kind=fPrec),         public,  save :: cdist_energy   = zero

  ! Twiss
  real(kind=fPrec),         public,  save :: cdist_alphaX   = zero
  real(kind=fPrec),         public,  save :: cdist_alphaY   = zero
  real(kind=fPrec),         public,  save :: cdist_betaX    = zero
  real(kind=fPrec),         public,  save :: cdist_betaY    = zero
  real(kind=fPrec),         private, save :: cdist_gammaX   = zero
  real(kind=fPrec),         private, save :: cdist_gammaY   = zero
  real(kind=fPrec),         public,  save :: cdist_emitX    = zero
  real(kind=fPrec),         public,  save :: cdist_emitY    = zero

  ! Distribution Settings
  real(kind=fPrec),         public,  save :: cdist_ampX     = zero
  real(kind=fPrec),         public,  save :: cdist_ampY     = zero
  real(kind=fPrec),         public,  save :: cdist_smearX   = zero
  real(kind=fPrec),         public,  save :: cdist_smearY   = zero
  real(kind=fPrec),         public,  save :: cdist_spreadE  = zero
  real(kind=fPrec),         public,  save :: cdist_bunchLen = zero

  character(len=mFileName), public,  save :: cdist_fileName = " "

contains

subroutine cdist_makeDist(distFormat)

  use crcoall

  integer, intent(in) :: distFormat

  cdist_gammaX = (one + cdist_alphaX**2)/cdist_betaX
  cdist_gammaY = (one + cdist_alphaY**2)/cdist_betaY

  select case(distFormat)
  case(0)
    return
  case(1)
    call cdist_makeDist_fmt1
  case(2)
    call cdist_makeDist_fmt2
  case default
    write(lout,"(a)") "COLLDIST> ERROR Unknown distribution format. Valid is 0 to 6, got ",distFormat
  end select

end subroutine cdist_makeDist

! ================================================================================================ !
!  Generation of Distribution Format 1
!  This routine generates particles in phase space X/XP and Y/YP ellipses, as defined in the input
!  parameters. Distribution is flat in the band. X and Y are fully uncorrelated.
! ================================================================================================ !
subroutine cdist_makeDist_fmt1

  use crcoall
  use mod_ranlux
  use mathlib_bouncer
  use mod_common, only : napx
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv

  implicit none

  real(kind=fPrec) :: emitX, emitY, sigmaX, sigmaY
  integer          :: j

  if(cdist_ampX > zero) then
    do j=1, napx
      emitX  = cdist_emitX*(cdist_ampX + ((two*real(rndm4()-half,fPrec))*cdist_smearX))**2
      sigmaX = sqrt(cdist_betaX*emitX)
      xv1(j) = sigmaX * sin_mb(twopi*real(rndm4(),fPrec))
      if(rndm4() > half) then
        yv1(j) = sqrt(emitX/cdist_betaX-xv1(j)**2/cdist_betaX**2)-(cdist_alphaX*xv1(j))/cdist_betaX
      else
        yv1(j) = -one*sqrt(emitX/cdist_betaX-xv1(j)**2/cdist_betaX**2)-(cdist_alphaX*xv1(j))/cdist_betaX
      end if
    end do
  else
    xv1(:) = zero
    yv1(:) = zero
  end if

  if(cdist_ampY > zero) then
    do j=1, napx
      emitY  = cdist_emitY*(cdist_ampY + ((two*real(rndm4()-half,fPrec))*cdist_smearY))**2
      sigmaY = sqrt(cdist_betaY*emitY)
      xv2(j) = sigmaY * sin_mb(twopi*real(rndm4(),fPrec))
      if(rndm4() > half) then
        yv2(j) = sqrt(emitY/cdist_betaY-xv2(j)**2/cdist_betaY**2)-(cdist_alphaY*xv2(j))/cdist_betaY
      else
        yv2(j) = -one*sqrt(emitY/cdist_betaY-xv2(j)**2/cdist_betaY**2)-(cdist_alphaY*xv2(j))/cdist_betaY
      end if
    end do
  else
    xv2(:) = zero
    yv2(:) = zero
  end if

  ejv(:)   = cdist_energy
  sigmv(:) = zero

end subroutine cdist_makeDist_fmt1

! ================================================================================================ !
!  Generation of Distribution Format 2
!  Uses format 1, and generates the transverse beam size in the direction set to zero in fort.3
! ================================================================================================ !
subroutine cdist_makeDist_fmt2

  use crcoall
  use mathlib_bouncer
  use mod_ranlux
  use mod_common, only : napx
  use mod_common_main, only : xv1, xv2, yv1, yv2, ejv, sigmv

  implicit none

  real(kind=fPrec) :: iiX, iiY, phiX, phiY
  integer          :: j

  if(cdist_ampX > zero .and. cdist_ampY > zero) then
    write(lout,"(a)") "COLLDIST> ERROR Distribution parameters for format 2 are incorrectly set."
    write(lout,"(a)") "COLLDIST>       Both X and Y amplitude is larger than zero. Use format 1 instead."
    call prror
  end if

  call cdist_makeDist_fmt1

  if(cdist_ampX < pieni) then
    do j=1,napx
      phiX   = twopi*real(rndm4(),fPrec)
      iiX    = (-one*cdist_emitX) * log_mb(real(rndm4(),fPrec))
      xv1(j) = sqrt((two*iiX)*cdist_betaX) * cos_mb(phiX)
      yv1(j) = (-one*sqrt((two*iiX)/cdist_betaX)) * (sin_mb(phiX) + cdist_alphaX * cos_mb(phiX))
    end do
  end if

  if(cdist_ampY < pieni) then
    do j=1,napx
      phiY   = twopi*real(rndm4(),fPrec)
      iiY    = (-one*cdist_emitY) * log_mb(real(rndm4(),fPrec))
      xv2(j) = sqrt((two*iiY)*cdist_betaY) * cos_mb(phiY)
      yv2(j) = (-one*sqrt((two*iiY)/cdist_betaY)) * (sin_mb(phiY) + cdist_alphaY * cos_mb(phiY))
    end do
  end if

end subroutine cdist_makeDist_fmt2

end module coll_dist
