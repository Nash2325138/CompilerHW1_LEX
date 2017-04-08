l = 'void   int   double   bool   char   null   for   while   do   if   else   switch return   break   continue   const   true   false   struct   case   default'
l = l.split('   ')
print('|'.join([' "'+s+'" ' for s in l]))

l = '+   -   *   /   \%   ++   --   <   <=   >   >=   ==   !=   =   &&   ||   !   \
*   &'.split('   ')
print('|'.join([' "'+s+'" ' for s in l]))

l = ': ; , . [ ] ( ) { }'.split(' ')
print('|'.join([' "'+s+'" ' for s in l]))
