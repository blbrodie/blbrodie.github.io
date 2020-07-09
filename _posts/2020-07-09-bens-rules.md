### Timezone Rules
1. Get your datatypes right - use dates for datetimes. Don't convert.
2. Always use UTC except at the edges of the system.
3. Don't underestimate timezone issues.
4. Always check for timezone problems in tests.
5. Never ever ever convert from a date to a datetime.

### Uncategorized
6. Your database is not your application
