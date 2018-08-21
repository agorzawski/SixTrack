! start include/kicka04h.f90
#ifndef TILT
  mpe=4
  mx=2
  cxzr=xl
  cxzi=zl
  cxzyr=cxzr**2-cxzi**2                                            !hr08
  cxzyi=cxzr*cxzi+cxzi*cxzr
  qu=(three*ekk)*cxzyr                                             !hr02
  qv=(three*ekk)*cxzyi                                             !hr02
  ab2(2)=-one*qv                                                   !hr02
  cxzyrr=cxzyr*cxzr-cxzyi*cxzi
  cxzyi=cxzyr*cxzi+cxzyi*cxzr
  cxzyr=cxzyrr
  dyy1=ekk*cxzyr
  dyy2=(-one*ekk)*cxzyi                                            !hr02
  ab1(3)=(three*ekk)*xl                                            !hr02
  ab2(3)=((-one*three)*ekk)*zl                                     !hr02
  ab1(4)=ekk
#else
  mpe=4
  mx=2
  cxzr=xl
  cxzi=zl
  cxzyr=cxzr**2-cxzi**2                                            !hr08
  cxzyi=cxzr*cxzi+cxzi*cxzr
  tiltck=tiltc(k)**2-tilts(k)**2                                   !hr08
  tiltsk=(two*tiltc(k))*tilts(k)                                   !hr02
  qu=(three*ekk)*(tiltck*cxzyr+tiltsk*cxzyi)                       !hr02
  qv=(three*ekk)*(tiltck*cxzyi-tiltsk*cxzyr)                       !hr02
  ab1(2)=qu
  ab2(2)=-one*qv                                                   !hr02
  cxzyrr=cxzyr*cxzr-cxzyi*cxzi
  cxzyi=cxzyr*cxzi+cxzyi*cxzr
  cxzyr=cxzyrr
  dyy1=ekk*(tiltc(k)*cxzyr+tilts(k)*cxzyi)
  dyy2=ekk*(tilts(k)*cxzyr-tiltc(k)*cxzyi)                         !hr02
  tiltckuk=tiltck*tiltc(k)-tiltsk*tilts(k)
  tiltsk=tiltck*tilts(k)+tiltsk*tiltc(k)
  tiltck=tiltckuk
  ab1(3)=(three*ekk)*(tiltck*xl+tiltsk*zl)                         !hr02
  ab2(3)=(three*ekk)*(tiltsk*xl-tiltck*zl)                         !hr02
  tiltckuk=tiltck*tiltc(k)-tiltsk*tilts(k)
  tiltsk=tiltck*tilts(k)+tiltsk*tiltc(k)
  tiltck=tiltckuk
  ab1(4)=ekk*tiltck
  ab2(4)=ekk*tiltsk
#endif
! end include/kicka04h.f90