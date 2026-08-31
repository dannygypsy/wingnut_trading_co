export default defineEventHandler(async () => {
    return prisma.inventoryCategory.findMany({
        orderBy: [{ sort_order: 'asc' }, { name: 'asc' }]
    })
})