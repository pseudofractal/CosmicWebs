FC = gfortran
FFLAGS = -fdefault-real-8 # -auto
#-prec_div -mp -fpe1 -fp_port -fltconsistency
#OPTFLAGS = -O0 -CB
OPTFLAGS = 
#
objects = treedefs.o fft.o initialise.o
#
init.x : $(objects)
	$(FC) $(FFLAGS) $(OPTFLAGS) -o init.x $(objects)
#
initialise.o : initialise.f90 treedefs.o fft.o
	$(FC) -c $(FFLAGS) $(OPTFLAGS) initialise.f90
#
fft.o : fft.f90
	$(FC) -c $(FFLAGS) $(OPTFLAGS) fft.f90
#
treedefs.o : treedefs.f90
	$(FC) -c $(FFLAGS) $(OPTFLAGS) treedefs.f90
#
clean : 
	rm $(objects) 
#
