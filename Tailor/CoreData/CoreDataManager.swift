//
//  CoreDataManager.swift
//  Tailor
//
//  Created by Karen Khachatryan on 02.12.24.
//


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tailor")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveOrder(orderModel: OrderModel, completion: @escaping (Error?) -> Void) {
        let id = orderModel.id
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                let order: Order
                
                if let existingOrder = results.first {
                    order = existingOrder
                } else {
                    order = Order(context: backgroundContext)
                    order.id = id
                }
                    
                order.date = orderModel.date
                order.client = orderModel.client
                order.phoneNumber = orderModel.phoneNumber
                order.costOfMaterials = orderModel.costOfMaterials ?? 0
                order.productCost = orderModel.productCost ?? 0
                order.priority = Int32(orderModel.priority ?? 0)
                order.info = orderModel.info
                order.completionDate = orderModel.completionDate
                order.isCompleted = orderModel.isCompleted
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchOrders(completion: @escaping ([OrderModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var ordersModel: [OrderModel] = []
                for result in results {
                    let orderModel = OrderModel(id: result.id ?? UUID(), date: result.date ?? Date().stripTime(), client: result.client, phoneNumber: result.phoneNumber, costOfMaterials: result.costOfMaterials, productCost: result.productCost, priority: Int(result.priority), info: result.info, completionDate: result.completionDate, isCompleted: result.isCompleted)
                    ordersModel.append(orderModel)
                }
                DispatchQueue.main.async {
                    completion(ordersModel, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func savePortfolio(portfolioModel: PortfolioModel, completion: @escaping (Error?) -> Void) {
        let id = portfolioModel.id
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Portfolio> = Portfolio.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                let portfolio: Portfolio
                
                if let existingPortfolio = results.first {
                    portfolio = existingPortfolio
                } else {
                    portfolio = Portfolio(context: backgroundContext)
                    portfolio.id = id
                }
                
                portfolio.fur = portfolioModel.fur
                portfolio.info = portfolioModel.info
                portfolio.photos = portfolioModel.photos
                
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func confirmOrder(id: UUID, completion: @escaping (Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                if let order = results.first {
                    order.isCompleted = true
                    order.completionDate = Date().stripTime()
                } else {
                    completion(NSError(domain: "CoreDataManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Order not found"]))
                }
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchPortfolio(completion: @escaping ([PortfolioModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Portfolio> = Portfolio.fetchRequest()
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var portfolioModels: [PortfolioModel] = []
                for result in results {
                    let portfolioModel = PortfolioModel(id: result.id ?? UUID(), fur: result.fur, info: result.info, photos: result.photos ?? [])
                    portfolioModels.append(portfolioModel)
                }
                DispatchQueue.main.async {
                    completion(portfolioModels, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
    
    func fetchCompletedOrders(completion: @escaping ([OrderModel], Error?) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isCompleted == true")
            
            do {
                let results = try backgroundContext.fetch(fetchRequest)
                var ordersModel: [OrderModel] = []
                for result in results {
                    let orderModel = OrderModel(
                        id: result.id ?? UUID(),
                        date: result.date ?? Date().stripTime(),
                        client: result.client,
                        phoneNumber: result.phoneNumber,
                        costOfMaterials: result.costOfMaterials,
                        productCost: result.productCost,
                        priority: Int(result.priority),
                        info: result.info,
                        completionDate: result.completionDate,
                        isCompleted: result.isCompleted
                    )
                    ordersModel.append(orderModel)
                }
                DispatchQueue.main.async {
                    completion(ordersModel, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
    }
}

